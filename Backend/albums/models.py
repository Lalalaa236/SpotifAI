from django.db import models
from artists.models import Artist

class Album(models.Model):
    title = models.CharField(max_length=255)
    artist = models.ForeignKey(Artist, on_delete=models.CASCADE, related_name="albums")
    release_date = models.DateField()
    cover_image = models.URLField(blank=True, null=True)

    def __str__(self):
        return f"{self.title} - {self.artist.name}"
