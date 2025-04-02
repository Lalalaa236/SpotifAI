from django.db import models
from django.contrib.auth.models import User
from songs.models import Song

class Playlist(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="playlists")
    name = models.CharField(max_length=255)
    created_at = models.DateTimeField(auto_now_add=True)
    songs = models.ManyToManyField(Song, related_name="playlists")

    def __str__(self):
        return f"{self.name} ({self.user.username})"
