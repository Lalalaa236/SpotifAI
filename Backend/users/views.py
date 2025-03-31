from django.shortcuts import render
from rest_framework import viewsets, status, generics
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework_simplejwt.tokens import RefreshToken
from .models import User
from .serializers import UserSerializer, GoogleAuthSerializer
import google.oauth2.id_token
from google.auth.transport import requests

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    
    def get_permissions(self):
        if self.action == 'create' or self.action == 'google_auth':
            return [AllowAny()]
        return [IsAuthenticated()]
    
    @action(detail=False, methods=['post'], permission_classes=[AllowAny])
    def google_auth(self, request):
        serializer = GoogleAuthSerializer(data=request.data)
        if serializer.is_valid():
            google_id = serializer.validated_data['google_id']
            email = serializer.validated_data['email']
            name = serializer.validated_data['name']
            
            try:
                user = User.objects.get(email=email)
                # Update Google ID if not set
                if not user.google_id:
                    user.google_id = google_id
                    user.is_google_user = True
                    user.save()
            except User.DoesNotExist:
                user = User.objects.create(
                    email=email,
                    username=name,
                    google_id=google_id,
                    is_google_user=True
                )
            
            # Generate tokens
            refresh = RefreshToken.for_user(user)
            return Response({
                'refresh': str(refresh),
                'access': str(refresh.access_token),
                'user': UserSerializer(user).data
            })
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class CreateUserView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [AllowAny]