from rest_framework import viewsets, status
from rest_framework.decorators import action, api_view
from rest_framework.response import Response
from django.contrib.auth.hashers import make_password, check_password
from django.contrib.auth import logout
from django.contrib.auth.models import User
from .models import User
from .serializers import UserSerializer
from playlists.models import Playlist
from playlists.serializers import PlaylistSerializer
from subscriptions.models import Subscription
from subscriptions.serializers import SubscriptionSerializer
from chathistory.models import ChatHistory
from chathistory.serializers import ChatHistorySerializer

from django.shortcuts import render
from django.contrib.auth.models import User
from rest_framework import generics
from .serializers import UserSerializer
from rest_framework.permissions import IsAuthenticated, AllowAny

class CreateUserView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [AllowAny]

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def create(self, request, *args, **kwargs):
        request.data['password'] = make_password(request.data['password'])
        return super().create(request, *args, **kwargs)

    @action(detail=False, methods=['post'])
    def login(self, request):
        username = request.data.get('username')
        password = request.data.get('password')

        try:
            user = User.objects.get(username=username)
            serializer = UserSerializer(user)
            if check_password(password, user.password):
                return Response({
                    "status": "success",
                    "data": serializer.data
                })
            return Response({
                "status": "failed",
                "message": "Invalid password"
            }, status=status.HTTP_401_UNAUTHORIZED)
        except User.DoesNotExist:
            return Response({
                "status": "failed",
                "message": "User not found"
            }, status=status.HTTP_404_NOT_FOUND)
        
    @action(detail=False, methods=['post'])
    def logout_view(request):
        logout(request)
        return Response({
            "status": "success",
            "message": "Logged out successfully"
        })

    @action(detail=True, methods=['put'])
    def change_password(self, request, pk=None):
        user = self.get_object()
        old_password = request.data.get('old_password')
        new_password = request.data.get('new_password')

        if not check_password(old_password, user.password):
            return Response({
                "status": "failed",
                "message": "Invalid old password"
            }, status=status.HTTP_400_BAD_REQUEST)

        user.password = make_password(new_password)
        user.save()
        return Response({
            "status": "success",
            "message": "Password changed successfully"
        })

    @action(detail=True, methods=['get'])
    def profile(self, request, pk=None):
        user = self.get_object()
        playlists = Playlist.objects.filter(user=user)

        try:
            subscription = Subscription.objects.get(user=user)
            subscription_data = SubscriptionSerializer(subscription).data
        except Subscription.DoesNotExist:
            subscription_data = None

        return Response({
            "status": "success",
            "user_id": user.user_id,
            "username": user.username,
            "email": user.email,
            "playlists": PlaylistSerializer(playlists, many=True).data,
            "subscription": subscription_data
        })

    @action(detail=True, methods=['get'])
    def playlists(self, request, pk=None):
        user = self.get_object()
        playlists = Playlist.objects.filter(user=user)
        serializer = PlaylistSerializer(playlists, many=True)

        return Response({
            "status": "success",
            "data": serializer.data
        })

    @action(detail=True, methods=['get'])
    def subscription(self, request, pk=None):
        user = self.get_object()

        try:
            subscription = Subscription.objects.get(user=user)
            serializer = SubscriptionSerializer(subscription)
            return Response({
                "status": "success",
                "data": serializer.data
            })
        except Subscription.DoesNotExist:
            return Response({
                "status": "failed",
                "message": "No subscription found"
            }, status=status.HTTP_404_NOT_FOUND)

    @action(detail=True, methods=['get'])
    def chat_history(self, request, pk=None):
        user = self.get_object()
        chat_history = ChatHistory.objects.filter(user=user)
        serializer = ChatHistorySerializer(chat_history, many=True)

        return Response({
            "status": "success",
            "data": serializer.data
        })

    @action(detail=False, methods=['post'])
    def social_login(self, request):
        provider = request.data.get('provider')
        provider_user_id = request.data.get('provider_user_id')
        email = request.data.get('email')
        access_token = request.data.get('access_token')

        if not provider or not provider_user_id or not email:
            return Response({
                "status": "failed",
                "message": "Missing required fields"
            }, status=status.HTTP_400_BAD_REQUEST)

        user, created = User.objects.get_or_create(username=provider_user_id, defaults={
            'email': email,
            'password': make_password(access_token)
        })

        if not created:
            user.password = make_password(access_token)
            user.save()

        return Response({
            "status": "success",
            "message": "User logged in successfully",
            "user_id": user.id,
            "email": user.email
        })
