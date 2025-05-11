from django.db import models
from albums.models import Album
from artists.models import Artist
from genres.models import Genre

class Song(models.Model):
    title = models.CharField(max_length=255)
    album = models.ForeignKey(Album, on_delete=models.CASCADE, related_name="songs")
    artists = models.ManyToManyField(Artist, related_name="songs")
    audio_url = models.URLField(null=True, blank=True)
    cover_image = models.URLField(null=True, blank=True)
    genres = models.ManyToManyField(Genre, related_name="songs")

    def __str__(self):
        return self.title
