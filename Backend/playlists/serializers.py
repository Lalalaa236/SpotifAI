from rest_framework import serializers
from .models import Playlist
from songs.serializers import SongSerializer
from django.contrib.auth.models import User

class PlaylistSerializer(serializers.ModelSerializer):
    songs = SongSerializer(many=True, read_only=True)
    user = serializers.PrimaryKeyRelatedField(
        read_only=True,
        default=serializers.CurrentUserDefault()
    )
    
    class Meta:
        model = Playlist
        fields = '__all__'
