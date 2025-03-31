from django.shortcuts import render
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Artist
from .serializers import ArtistSerializer
from albums.models import Album
from albums.serializers import AlbumSerializer
from songs.models import Song
from songs.serializers import SongSerializer

class ArtistViewSet(viewsets.ModelViewSet):
    queryset = Artist.objects.all()
    serializer_class = ArtistSerializer
    
    @action(detail=True, methods=['get'])
    def albums(self, request, pk=None):
        artist = self.get_object()
        albums = Album.objects.filter(artist=artist.name)
        serializer = AlbumSerializer(albums, many=True)
        return Response({
            "status": "success",
            "data": serializer.data
        })
    
    @action(detail=True, methods=['get'])
    def songs(self, request, pk=None):
        artist = self.get_object()
        songs = Song.objects.filter(artist=artist.name)
        serializer = SongSerializer(songs, many=True)
        return Response({
            "status": "success",
            "data": serializer.data
        })
