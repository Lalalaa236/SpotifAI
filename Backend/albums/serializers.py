from rest_framework import serializers
from .models import Album
from artists.serializers import ArtistSerializer

class AlbumSerializer(serializers.ModelSerializer):
    artist = ArtistSerializer(read_only=True)

    class Meta:
        model = Album
        fields = '__all__'
