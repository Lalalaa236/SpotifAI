from rest_framework import serializers
from .models import Album

class AlbumSerializer(serializers.ModelSerializer):
    class Meta:
        model = Album
        fields = ['album_id', 'title', 'artist', 'release_date', 'cover_image', 'user']