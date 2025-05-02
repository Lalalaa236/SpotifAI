from rest_framework import serializers
from .models import Song
from artists.serializers import ArtistSerializer
from genres.serializers import GenreSerializer

class SongSerializer(serializers.ModelSerializer):
    artists = ArtistSerializer(many=True, read_only=True)
    genres = GenreSerializer(many=True, read_only=True)
    class Meta:
        model = Song
        fields = '__all__'
