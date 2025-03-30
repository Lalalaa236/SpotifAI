from django.contrib import admin
from django.urls import path, include
from users.views import UserViewSet, CreateUserView
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView


from rest_framework.routers import DefaultRouter
from subscriptions.views import SubscriptionViewSet
from playlists.views import PlaylistViewSet
from songs.views import SongViewSet
from chathistory.views import ChatHistoryViewSet
from chatbot.views import ChatBotViewSet

router = DefaultRouter()
router.register(r'users', UserViewSet)
router.register(r'subscriptions', SubscriptionViewSet)
router.register(r'playlists', PlaylistViewSet)
router.register(r'songs', SongViewSet)
router.register(r'chat-history', ChatHistoryViewSet)
router.register(r'chatbot', ChatBotViewSet)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include(router.urls)),
    path('api/register/', CreateUserView.as_view(), name='register'),  # Add direct URL pattern
    path('api/token/', TokenObtainPairView.as_view(), name='getToken'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='refreshToken'),
    path('api-auth/', include('rest_framework.urls')),

    path('accounts/', include('allauth.urls')),
    path('', include('users.urls')),
]
