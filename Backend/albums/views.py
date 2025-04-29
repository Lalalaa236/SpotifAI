from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response

from .models import Album
from .serializers import AlbumSerializer
from artists.models import Artist
from songs.models import Song
from songs.serializers import SongSerializer


class AlbumViewSet(viewsets.ModelViewSet):
    queryset = Album.objects.all()
    serializer_class = AlbumSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    
    @action(detail=True, methods=['post'])
    def add_song(self, request, pk=None):
        album = self.get_object()
        try:
            song_id = request.data.get('song_id')
            song = Song.objects.get(id=song_id)
            
            if song.album == album:
                return Response(
                    {"error": "Song already in this album"}, 
                    status=status.HTTP_400_BAD_REQUEST
                )
                
            song.album = album
            song.save()
            
            return Response(
                {"message": f"Song '{song.title}' added to album '{album.title}'"}, 
                status=status.HTTP_200_OK
            )
        except Song.DoesNotExist:
            return Response(
                {"error": "Song not found"}, 
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            return Response(
                {"error": str(e)}, 
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=True, methods=['post'])
    def remove_song(self, request, pk=None):
        album = self.get_object()
        try:
            song_id = request.data.get('song_id')
            song = Song.objects.get(id=song_id)
            
            if song.album != album:
                return Response(
                    {"error": "Song not in this album"}, 
                    status=status.HTTP_400_BAD_REQUEST
                )
                
            song.album = None
            song.save()
            
            return Response(
                {"message": f"Song '{song.title}' removed from album '{album.title}'"}, 
                status=status.HTTP_200_OK
            )
        except Song.DoesNotExist:
            return Response(
                {"error": "Song not found"}, 
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            return Response(
                {"error": str(e)}, 
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=False, methods=['post'])
    def create_for_artist(self, request):
        try:
            artist_id = request.data.get('artist_id')
            artist = Artist.objects.get(id=artist_id)
            
            serializer = self.get_serializer(data=request.data)
            if serializer.is_valid():
                serializer.save(artist=artist)
                return Response(serializer.data, status=status.HTTP_201_CREATED)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except Artist.DoesNotExist:
            return Response(
                {"error": "Artist not found"}, 
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            return Response(
                {"error": str(e)}, 
                status=status.HTTP_400_BAD_REQUEST
            )

    @action(detail=True, methods=['get'])
    def get_all_songs(self, request, pk=None):
        try:
            album = self.get_object()
            songs = Song.objects.filter(album=album)
            serializer = SongSerializer(songs, many=True)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Album.DoesNotExist:
            return Response(
                {"error": "Album not found"},
                status=status.HTTP_404_NOT_FOUND
            )

    @action(detail=False, methods=['get'])
    def search_album(self, request):
        query = request.query_params.get('q', '')
        albums = Album.objects.filter(title__icontains=query)
        serializer = self.get_serializer(albums, many=True)
        return Response(serializer.data)
