from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),    
    path('api/v1/accounts/', include([
        path('', include('allauth.urls')),
        path('', include('users.urls')),
    ])),
    path('api/v1/artists/', include('artists.urls')),
    path('api/v1/albums/', include('albums.urls')),
    path('api/v1/songs/', include('songs.urls')),
    path('api/v1/playlists/', include('playlists.urls')),
]
