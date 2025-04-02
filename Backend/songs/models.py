from django.db import models
from albums.models import Album

class Song(models.Model):
    title = models.CharField(max_length=255)
    album = models.ForeignKey(Album, on_delete=models.CASCADE, related_name="songs")
    duration = models.PositiveIntegerField(help_text="Duration in seconds")
    audio_file = models.FileField(upload_to="songs/")

    def __str__(self):
        return self.title
