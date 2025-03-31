from django.shortcuts import render
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Album
from .serializers import AlbumSerializer
from songs.models import Song
from songs.serializers import SongSerializer

class AlbumViewSet(viewsets.ModelViewSet):
    queryset = Album.objects.all()
    serializer_class = AlbumSerializer
    
    def get_queryset(self):
        user_id = self.request.query_params.get('user_id')
        if user_id:
            return Album.objects.filter(user_id=user_id)
        return Album.objects.all()
    
    @action(detail=True, methods=['get'])
    def songs(self, request, pk=None):
        album = self.get_object()
        songs = Song.objects.filter(album_id=album.album_id)
        serializer = SongSerializer(songs, many=True)
        return Response({
            "status": "success",
            "data": serializer.data
        })
