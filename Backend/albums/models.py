from django.db import models
from users.models import User

class Album(models.Model):
    album_id = models.AutoField(primary_key=True)
    title = models.CharField(max_length=255)
    artist = models.CharField(max_length=255)
    release_date = models.DateField()
    cover_image = models.URLField(null=True, blank=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='albums')
    
    def __str__(self):
        return f"{self.title} - {self.artist}"
