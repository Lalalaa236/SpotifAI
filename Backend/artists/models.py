from django.db import models

class Artist(models.Model):
    artist_id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=255)
    bio = models.TextField(null=True, blank=True)
    image = models.URLField(null=True, blank=True)
    
    def __str__(self):
        return self.name
