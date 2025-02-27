from rest_framework import serializers
from .models import Song

class SongSerializer(serializers.ModelSerializer):
    class Meta:
        model = Song
        fields = ['song_id', 'title', 'artist', 'album', 'genre', 'duration', 'playlist']