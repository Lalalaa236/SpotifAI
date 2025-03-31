from django.shortcuts import render
from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Genre
from .serializers import GenreSerializer
from songs.models import Song
from songs.serializers import SongSerializer

class GenreViewSet(viewsets.ModelViewSet):
    queryset = Genre.objects.all()
    serializer_class = GenreSerializer
    
    @action(detail=True, methods=['get'])
    def songs(self, request, pk=None):
        genre = self.get_object()
        songs = Song.objects.filter(genre=genre.name)
        serializer = SongSerializer(songs, many=True)
        return Response({
            "status": "success",
            "data": serializer.data
        })
