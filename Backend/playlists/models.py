from django.db import models
from django.contrib.auth.models import User
from songs.models import Song

class Playlist(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="playlists")
    name = models.CharField(max_length=255)
    created_at = models.DateTimeField(auto_now_add=True)
    songs = models.ManyToManyField(Song, related_name="playlists")
    cover_image = models.URLField(blank=True, null=True, default='https://d1m06rjnqs2z9j.cloudfront.net/playlist-cover/placeholder.png')

    def __str__(self):
        return f"{self.name} ({self.user.username})"
