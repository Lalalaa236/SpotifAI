from rest_framework import serializers
from .models import Conversation, Message
from songs.serializers import SongSerializer

class MessageSerializer(serializers.ModelSerializer):
    recommended_songs = SongSerializer(many=True, read_only=True)
    
    class Meta:
        model = Message
        fields = ['id', 'role', 'content', 'timestamp', 'recommended_songs']

class ConversationSerializer(serializers.ModelSerializer):
    messages = MessageSerializer(many=True, read_only=True)
    
    class Meta:
        model = Conversation
        fields = ['id', 'user', 'created_at', 'updated_at', 'messages']

class ChatInputSerializer(serializers.Serializer):
    message = serializers.CharField(required=True)
    conversation_id = serializers.IntegerField(required=False, allow_null=True)

class ChatResponseSerializer(serializers.Serializer):
    conversation_id = serializers.IntegerField()
    message = serializers.CharField()
    songs = SongSerializer(many=True, required=False)