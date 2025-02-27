from rest_framework import viewsets
from .models import ChatHistory
from .serializers import ChatHistorySerializer

class ChatHistoryViewSet(viewsets.ModelViewSet):
    queryset = ChatHistory.objects.all()
    serializer_class = ChatHistorySerializer