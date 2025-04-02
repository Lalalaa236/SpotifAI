from django.contrib import admin
from django.urls import path, include

# API v1 URL patterns
api_v1_patterns = [
    path('accounts/', include('allauth.urls')),
    path('users/', include('users.urls')),
    path('', include('artists.urls')),
    path('', include('albums.urls')),
    path('', include('songs.urls')),
    path('', include('playlists.urls')),
]

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/v1/', include(api_v1_patterns)),
]
