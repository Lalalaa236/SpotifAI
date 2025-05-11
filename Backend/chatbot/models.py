from django.db import models
from django.contrib.auth.models import User
from songs.models import Song  # Import Song model

class Conversation(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='conversations')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"Conversation with {self.user.username} on {self.created_at.strftime('%Y-%m-%d')}"

class Message(models.Model):
    ROLE_CHOICES = [
        ('user', 'User'),
        ('assistant', 'Assistant'),
    ]
    
    conversation = models.ForeignKey(Conversation, on_delete=models.CASCADE, related_name='messages')
    role = models.CharField(max_length=10, choices=ROLE_CHOICES)
    content = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)
    recommended_songs = models.ManyToManyField(Song, blank=True, related_name='recommendations')
    
    class Meta:
        ordering = ['timestamp']
        
    def __str__(self):
        return f"{self.role}: {self.content}"
