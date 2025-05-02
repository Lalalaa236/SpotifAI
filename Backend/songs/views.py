from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response

from .models import Song
from .serializers import SongSerializer
from artists.models import Artist
from albums.models import Album

class SongViewSet(viewsets.ModelViewSet):
    queryset = Song.objects.all()
    serializer_class = SongSerializer

    @action(detail=True, methods=['get'])
    def details(self, request, pk=None):
        try:
            song = self.get_object()
            serializer = self.get_serializer(song)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Song.DoesNotExist:
            return Response(
                {"error": "Song not found"},
                status=status.HTTP_404_NOT_FOUND
            )

    @action(detail=False, methods=['get'])
    def find_song(self, request):
        query = request.query_params.get('q', '')
        songs = Song.objects.filter(title__icontains=query)
        serializer = self.get_serializer(songs, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    @action(detail=False, methods=['get'])
    def fetch_songs_by_artist(self, request):
        artist_id = request.query_params.get('artist_id')
        try:
            # Direct query using the many-to-many relationship
            songs = Song.objects.filter(artists__id=artist_id)
            if not songs.exists():
                return Response(
                    {"error": "No songs found for the given artist."},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            serializer = self.get_serializer(songs, many=True)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Exception as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
