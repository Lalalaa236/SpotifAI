from django.db import models
from chathistory.models import ChatHistory

class ChatBot(models.Model):
    bot_id = models.AutoField(primary_key=True)
    llm_model = models.CharField(max_length=255)
    chatHistory = models.ForeignKey(ChatHistory, on_delete=models.CASCADE)

    def __str__(self):
        return f"ChatBot {self.bot_id}"