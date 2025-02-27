from django.shortcuts import render
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Playlist
from songs.models import Song
from .serializers import PlaylistSerializer
from songs.serializers import SongSerializer
from users.models import User

class PlaylistViewSet(viewsets.ModelViewSet):
    queryset = Playlist.objects.all()
    serializer_class = PlaylistSerializer

    def get_queryset(self):
        user_id = self.request.query_params.get('user_id')

        if user_id:
            return Playlist.objects.filter(user_id=user_id)
        return Playlist.objects.all()

    @action(detail=True, methods=['get'])
    def songs(self, request, pk=None):
        playlist = self.get_object()
        songs = playlist.songs.all()
        serializer = SongSerializer(songs, many=True)

        return Response({
            "status": "success",
            "data": serializer.data
        })

    @action(detail=True, methods=['post'])
    def add_song(self, request, pk=None):
        playlist = self.get_object()
        song_id = request.data.get('song_id')

        if not song_id:
            return Response({
                "status": "failed",
                "message": "Song ID is required"
            }, status=status.HTTP_400_BAD_REQUEST)

        try:
            song = Song.objects.get(pk=song_id)
            song.playlist = playlist
            song.save()
            return Response({
                "status": "success",
                "message": "Song added to playlist"
            })
        except Song.DoesNotExist:
            return Response({
                "status": "failed",
                "message": "Song not found"
            }, status=status.HTTP_404_NOT_FOUND)
