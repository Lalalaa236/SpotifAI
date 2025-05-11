import os
import json
from django.conf import settings
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated

from django.shortcuts import render

from .models import Conversation, Message
from .serializers import ConversationSerializer, MessageSerializer, ChatInputSerializer, ChatResponseSerializer
from songs.models import Song
from songs.serializers import SongSerializer
from artists.models import Artist
from albums.models import Album
from genres.models import Genre

import google.generativeai as genai

# Configure Gemini API
GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')
genai.configure(api_key=GEMINI_API_KEY)

class ChatbotViewSet(viewsets.ModelViewSet):
    queryset = Conversation.objects.all()
    serializer_class = ConversationSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return Conversation.objects.filter(user=self.request.user)
    
    def get_model(self):
        return genai.GenerativeModel('gemini-2.0-flash')
    
    @action(detail=False, methods=['post'])
    def chat(self, request):
        serializer = ChatInputSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        user = request.user
        message_content = serializer.validated_data['message']
        conversation_id = serializer.validated_data.get('conversation_id')
        
        # Get or create conversation
        if conversation_id:
            try:
                conversation = Conversation.objects.get(id=conversation_id, user=user)
            except Conversation.DoesNotExist:
                return Response({'error': 'Conversation not found'}, status=status.HTTP_404_NOT_FOUND)
        else:
            conversation = Conversation.objects.create(user=user)
        
        # Save user message
        user_message = Message.objects.create(
            conversation=conversation,
            role='user',
            content=message_content
        )
        
        # Check if message is about song recommendations
        is_recommendation = self._is_song_recommendation_request(message_content)
        print(f"Is recommendation request: {is_recommendation} for message: '{message_content}'")
        
        if is_recommendation:
            print("Handling as song recommendation")
            response_data = self._handle_song_recommendation(message_content, conversation)
            return Response(response_data)
        
        # Get conversation history for context - reformatted for Gemini API
        messages = conversation.messages.all().order_by('timestamp')
        gemini_messages = []
        
        # Add system prompt as a user message followed by model response
        gemini_messages.append({
            "role": "user", 
            "parts": ["You are a helpful music assistant for SpotifAI. You can discuss music, artists, genres, and provide recommendations."]
        })
        gemini_messages.append({
            "role": "model", 
            "parts": ["I'll be your music assistant for SpotifAI. How can I help you today?"]
        })
        
        # Convert conversation history to Gemini format
        for msg in messages:
            # Map 'assistant' role to 'model' for Gemini API
            role = "model" if msg.role == "assistant" else "user"
            gemini_messages.append({
                "role": role,
                "parts": [msg.content]
            })
        
        # Regular conversation with Gemini
        model = self.get_model()
        response = model.generate_content(gemini_messages)
        
        # Save assistant response
        assistant_message = Message.objects.create(
            conversation=conversation,
            role='assistant',
            content=response.text
        )
        
        return Response({
            'conversation_id': conversation.id,
            'message': assistant_message.content,
            'songs': []  # No songs for regular conversation
        })
    
    def _is_song_recommendation_request(self, message):
        message_lower = message.lower()
        
        # Expanded phrases that clearly indicate music requests
        recommendation_phrases = [
            # Recommendation requests
            "recommend music", "recommend me a song", "suggest a song", 
            "recommend songs", "song recommendation", "music recommendation",
            "suggest music", "recommend tracks", "recommend some songs",
            "looking for music like", "find me songs", "songs similar to",
            "songs like", "music like",
            
            # Direct song requests - add these
            "listen to", "want to hear", "play the song", "play song",
            "want to listen", "can i hear", "play music", "play a song"
        ]
        
        # Check for explicit phrases first
        for phrase in recommendation_phrases:
            if phrase in message_lower:
                return True
        
        # Direct song title pattern: "song named X", "song called X", etc.
        direct_patterns = [
            "song named", "song called", "track called", "track named",
            "titled", "title", "song title"
        ]
        
        for pattern in direct_patterns:
            if pattern in message_lower:
                return True
                
        # More conservative check as before
        request_verbs = ["recommend", "suggest", "find", "looking for", 
                        "listen", "play", "hear", "want"]  # Added more verbs
        music_nouns = ["song", "track", "music", "album", "artist"]
        
        # Check proximity
        words = message_lower.split()
        for i, word in enumerate(words):
            if any(verb in word for verb in request_verbs):
                start = max(0, i-5)
                end = min(len(words), i+6)
                context_words = words[start:end]
                if any(noun in context_word for context_word in context_words for noun in music_nouns):
                    return True
        
        return False
    
    def _handle_song_recommendation(self, query, conversation):
        # Use Gemini to extract search parameters from the query
        model = self.get_model()
        extraction_prompt = f"""
        Extract search parameters from this music request: "{query}"
        
        Return a JSON with these fields:
        - title (string or null): The song title the user wants to hear or is asking about
        - artist_name (string or null): The artist name mentioned
        - album_title (string or null): The album title mentioned
        - genre (string or null): The music genre mentioned
        
        For the title field:
        - If the user asks for a specific song (e.g., "I want to listen to Song Name" or "play Song Name"), extract "Song Name" as the title
        - If they say "a song named/called X", extract "X" as the title
        - If they mention a song title in any other way, extract it
        
        Only include fields that are explicitly mentioned. If a field is not mentioned, set it to null.
        Format the response as valid JSON only, with no additional text.
        """
        
        try:
            extraction_response = model.generate_content({
                "role": "user",
                "parts": [extraction_prompt]
            })
            search_params = json.loads(extraction_response.text)
            print(f"Extracted search params: {search_params}")
        except Exception as e:
            print(f"Error parsing search parameters: {str(e)}")
            search_params = {
                'title': None,
                'artist_name': None,
                'album_title': None,
                'genre': None
            }
            
            # Fallback extraction for direct title requests
            title_indicators = ["song named", "song called", "listen to", "play", "hear"]
            for indicator in title_indicators:
                if indicator in query.lower():
                    # Try to extract what comes after the indicator
                    parts = query.lower().split(indicator, 1)
                    if len(parts) > 1:
                        potential_title = parts[1].strip()
                        # Remove common stopwords at the beginning
                        for stopword in ["the", "a", "an"]:
                            if potential_title.startswith(stopword + " "):
                                potential_title = potential_title[len(stopword)+1:]
                        
                        # Cut off at the first punctuation or end of string
                        for punct in [",", ".", "!", "?", ";"]:
                            if punct in potential_title:
                                potential_title = potential_title.split(punct)[0]
                        
                        search_params['title'] = potential_title.strip()
                        print(f"Fallback extraction found title: {search_params['title']}")
                        break
        
        # Debug what was extracted
        print(f"Final search params: {search_params}")
        
        # Start with all songs
        songs_query = Song.objects.all()
        has_filters = False
        
        # Apply filters with broader matching for titles
        if search_params.get('title'):
            title_query = search_params['title'].strip()
            if len(title_query) > 1:  # Avoid single character searches
                songs_query = songs_query.filter(title__icontains=title_query)
                has_filters = True
                print(f"Searching for title containing: '{title_query}'")
        
        # Apply filters based on extracted parameters
        if search_params.get('artist_name'):
            songs_query = songs_query.filter(artists__name__icontains=search_params['artist_name'])
            has_filters = True
        
        if search_params.get('album_title'):
            songs_query = songs_query.filter(album__title__icontains=search_params['album_title'])
            has_filters = True
        
        if search_params.get('genre'):
            songs_query = songs_query.filter(genres__name__icontains=search_params['genre'])
            has_filters = True
        
        # For title searches, try to find exact matches first
        exact_matches = None
        if search_params.get('title') and len(search_params['title'].strip()) > 1:
            # Try case-insensitive exact match first
            title_query = search_params['title'].strip()
            exact_matches = Song.objects.filter(title__iexact=title_query)
            
            if exact_matches.exists():
                print(f"Found {exact_matches.count()} exact title matches")
                songs = exact_matches[:5]
                songs_data = SongSerializer(songs, many=True).data
                print(f"Exact title matches: {[song['title'] for song in songs_data]}")
                has_matches = True
            else:
                # Try word-by-word matching
                words = title_query.lower().split()
                if len(words) > 1:  # Multi-word title
                    # Try matching all words
                    from django.db.models import Q
                    query_filter = Q()
                    for word in words:
                        if len(word) > 2:  # Only use words longer than 2 chars
                            query_filter &= Q(title__icontains=word)
                    
                    if query_filter:
                        word_matches = Song.objects.filter(query_filter)
                        if word_matches.exists():
                            print(f"Found {word_matches.count()} word-by-word matches")
                            songs = word_matches[:5]
                            songs_data = SongSerializer(songs, many=True).data
                            print(f"Word matches: {[song['title'] for song in songs_data]}")
                            has_matches = True
        
        # Get distinct songs matching all criteria
        if has_filters:
            songs = songs_query.distinct()[:5]
            if songs.exists():
                print(f"Found {songs.count()} songs using specific filters")
                songs_data = SongSerializer(songs, many=True).data
                print(f"Recommended songs: {[song['title'] for song in songs_data]}")
        else:
            songs = Song.objects.none()
        
        # If no songs found with specific criteria, look for keywords
        if not songs.exists():
            print("No direct matches found, trying keyword search")
            # Extract keywords from the query
            keyword_prompt = f"""
            Extract ONLY the most important 3-5 search terms for finding music from this request: "{query}"
            Return ONLY a comma-separated list of keywords, no other text.
            Example output: rock, 80s, upbeat, guitar
            """
            
            try:
                keyword_response = model.generate_content({
                    "role": "user", 
                    "parts": [keyword_prompt]
                })
                keywords = [k.strip() for k in keyword_response.text.split(',')]
                print(f"Extracted keywords: {keywords}")
                
                # Try each keyword individually
                for keyword in keywords:
                    if len(keyword) > 2:  # Skip very short keywords
                        print(f"Searching with keyword: '{keyword}'")
                        # Use Q objects to search across multiple fields
                        from django.db.models import Q
                        keyword_query = Song.objects.filter(
                            Q(title__icontains=keyword) |
                            Q(artists__name__icontains=keyword) |
                            Q(album__title__icontains=keyword) |
                            Q(genres__name__icontains=keyword)
                        ).distinct()
                        
                        keyword_songs = keyword_query[:5]
                        if keyword_songs.exists():
                            songs = keyword_songs
                            songs_data = SongSerializer(songs, many=True).data
                            print(f"Found songs with keyword '{keyword}': {[song['title'] for song in songs_data]}")
                            break
            except Exception as e:
                print(f"Error in keyword extraction: {str(e)}")
        
        # If still no songs found, use random selection
        if not songs.exists():
            print("No matches found, using random selection with randomized ordering")
            import random
            # Get all song IDs
            all_song_ids = list(Song.objects.values_list('id', flat=True))
            # Shuffle the IDs
            random.shuffle(all_song_ids)
            # Take first 5
            if all_song_ids:
                selected_ids = all_song_ids[:5]
                # Query by ID to preserve the random order
                from django.db.models import Case, When, Value, IntegerField
                preserved_order = Case(
                    *[When(id=id, then=Value(i)) for i, id in enumerate(selected_ids)],
                    output_field=IntegerField()
                )
                songs = Song.objects.filter(id__in=selected_ids).order_by(preserved_order)
                songs_data = SongSerializer(songs, many=True).data
                print(f"Random songs: {[song['title'] for song in songs_data]}")
        
        # Generate response message with Gemini
        songs_data = SongSerializer(songs, many=True).data
        song_descriptions = "\n".join([
            f"- {song['title']} by {', '.join([artist['name'] for artist in song['artists']])}" 
            for song in songs_data
        ])
        
        # Create a more specific prompt using the search parameters
        recommendation_context = ""
        if search_params.get('title'):
            recommendation_context += f" song title '{search_params['title']}'"
        if search_params.get('artist_name'):
            recommendation_context += f" artist '{search_params['artist_name']}'"
        if search_params.get('album_title'):
            recommendation_context += f" album '{search_params['album_title']}'"
        if search_params.get('genre'):
            recommendation_context += f" genre '{search_params['genre']}'"
        
        if not recommendation_context:
            recommendation_context = "your music interests"
        
        # Detect if this was a direct song request or a recommendation request
        is_direct_request = False
        direct_request_phrases = ["listen to", "play", "hear", "song named", "song called"]
        for phrase in direct_request_phrases:
            if phrase in query.lower():
                is_direct_request = True
                break

        # Customize the prompt based on request type
        if is_direct_request:
            prompt = f"""
            The user asked to hear the song: "{query}"
            
            Here are the closest matches I found:
            
            {song_descriptions}
            
            Please generate a friendly response that:
            1. Acknowledges their request to hear the specific song
            2. Presents the found songs as potential matches
            3. For exact matches, be confident. For partial matches, acknowledge they might not be exactly what was requested
            4. Ask if any of these songs are what they were looking for
            
            Be conversational and helpful.
            """
        else:
            # Use the original recommendation prompt
            prompt = f"""
            Based on the request for {recommendation_context.strip()}: "{query}", here are some recommended songs:
            
            {song_descriptions}
            
            Please generate a friendly and helpful response that:
            1. Acknowledges the user's specific request
            2. Introduces these song recommendations and explains why each might be a good match
            3. Asks if they'd like to hear any of these or need other recommendations
            
            Be conversational and natural.
            """
        
        # Generate the response
        response = model.generate_content({
            "role": "user",
            "parts": [prompt]
        })
        
        # Save assistant response with associated songs
        assistant_message = Message.objects.create(
            conversation=conversation,
            role='assistant',
            content=response.text
        )
        
        # Add the recommended songs to the message
        assistant_message.recommended_songs.add(*songs)
        
        return {
            'conversation_id': conversation.id,
            'message': response.text,
            'songs': songs_data
        }
    
    @action(detail=False, methods=['get'])
    def conversations(self, request):
        """Get all conversations for the current user"""
        conversations = Conversation.objects.filter(user=request.user).order_by('-updated_at')
        serializer = ConversationSerializer(conversations, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['get'])
    def conversation_detail(self, request, pk=None):
        """Get details of a specific conversation"""
        try:
            conversation = Conversation.objects.get(id=pk, user=request.user)
        except Conversation.DoesNotExist:
            return Response({'error': 'Conversation not found'}, status=status.HTTP_404_NOT_FOUND)
        
        serializer = ConversationSerializer(conversation)
        return Response(serializer.data)
