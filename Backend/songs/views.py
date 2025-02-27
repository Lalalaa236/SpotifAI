from django.shortcuts import render
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Song
from .serializers import SongSerializer
from users.models import User

class SongViewSet(viewsets.ModelViewSet):
    queryset = Song.objects.all()
    serializer_class = SongSerializer

    def get_queryset(self):
        playlist_id = self.request.query_params.get('playlist_id', None)

        if playlist_id:
            return Song.objects.filter(playlist_id=playlist_id)
        return Song.objects.all()

    @action(detail=False, methods=['get'])
    def by_user(self, request):
        username = request.query_params.get('username')

        if username:
            songs = Song.objects.filter(playlist__user__username=username)
            serializer = SongSerializer(songs, many=True)
            return Response({
                "status": "success",
                "data": serializer.data
            })

        return Response({
            "status": "failed",
            "message": "Username parameter is required"
        }, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['get'])
    def by_playlist(self, request):
        playlist_name = request.query_params.get('playlist_name')

        if playlist_name:
            songs = Song.objects.filter(playlist__name=playlist_name)
            serializer = SongSerializer(songs, many=True)
            return Response({
                "status": "success",
                "data": serializer.data
            })

        return Response({
            "status": "failed",
            "message": "Playlist name parameter is required"
        }, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['get'])
    def by_genre(self, request):
        genre = request.query_params.get('genre')

        if genre:
            songs = Song.objects.filter(genre=genre)
            serializer = SongSerializer(songs, many=True)
            return Response({
                "status": "success",
                "data": serializer.data
            })

        return Response({
            "status": "failed",
            "message": "Genre parameter is required"
        }, status=status.HTTP_400_BAD_REQUEST)
