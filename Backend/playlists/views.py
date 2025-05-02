from rest_framework import viewsets, status, permissions
from rest_framework.decorators import action
from rest_framework.response import Response

from .models import Playlist
from .serializers import PlaylistSerializer
from songs.models import Song
from albums.models import Album


class PlaylistViewSet(viewsets.ModelViewSet):
    serializer_class = PlaylistSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Playlist.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
    
    @action(detail=True, methods=['post'])
    def add_song(self, request, pk=None):
        playlist = self.get_object()
        try:
            song_id = request.data.get('song_id')
            song = Song.objects.get(id=song_id)
            playlist.songs.add(song)
            return Response(
                {"message": f"Song '{song.title}' added to playlist '{playlist.name}'"}, 
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
        playlist = self.get_object()
        try:
            song_id = request.data.get('song_id')
            song = Song.objects.get(id=song_id)
            if song in playlist.songs.all():
                playlist.songs.remove(song)
                return Response(
                    {"message": f"Song '{song.title}' removed from playlist '{playlist.name}'"}, 
                    status=status.HTTP_200_OK
                )
            else:
                return Response(
                    {"error": "Song not in playlist"}, 
                    status=status.HTTP_400_BAD_REQUEST
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
    def add_album(self, request, pk=None):
        playlist = self.get_object()
        try:
            album_id = request.data.get('album_id')
            album = Album.objects.get(id=album_id)
            songs = Song.objects.filter(album=album)
            playlist.songs.add(*songs)
            return Response(
                {"message": f"All songs from album '{album.title}' added to playlist '{playlist.name}'"},
                status=status.HTTP_200_OK
            )
        except Album.DoesNotExist:
            return Response(
                {"error": "Album not found"},
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )