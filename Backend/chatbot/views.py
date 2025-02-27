from rest_framework import viewsets
from .models import ChatBot
from .serializers import ChatBotSerializer

class ChatBotViewSet(viewsets.ModelViewSet):
    queryset = ChatBot.objects.all()
    serializer_class = ChatBotSerializer