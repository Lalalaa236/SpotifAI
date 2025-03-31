from django.db import models
from playlists.models import Playlist
from albums.models import Album

class Song(models.Model):
    song_id = models.AutoField(primary_key=True)
    title = models.CharField(max_length=255)
    artist = models.CharField(max_length=255)
    album = models.ForeignKey(Album, on_delete=models.CASCADE, related_name='songs', null=True, blank=True)
    genre = models.CharField(max_length=100, null=True, blank=True)
    duration = models.DurationField()
    file_path = models.URLField(null=True, blank=True)
    playlist = models.ForeignKey(Playlist, on_delete=models.CASCADE, related_name='songs', null=True, blank=True)
    
    def __str__(self):
        return f"{self.title} - {self.artist}"
