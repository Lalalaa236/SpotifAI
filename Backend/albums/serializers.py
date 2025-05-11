from rest_framework import serializers
from .models import Album
from artists.serializers import ArtistSerializer
from artists.models import Artist

class AlbumSerializer(serializers.ModelSerializer):
    artist_detail = ArtistSerializer(source='artist', read_only=True)
    artist_id = serializers.PrimaryKeyRelatedField(
        source='artist',
        queryset=Artist.objects.all(),
        write_only=True
    )
    
    class Meta:
        model = Album
        fields = ['id', 'title', 'artist_detail', 'artist_id', 'release_date', 'cover_image']
