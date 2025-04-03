from django.contrib import admin
from django.urls import path, include
from rest_framework import permissions
from drf_yasg.views import get_schema_view
from drf_yasg import openapi

# API v1 URL patterns
api_v1_patterns = [
    path('accounts/', include('allauth.urls')),
    path('users/', include('users.urls')),
    path('', include('artists.urls')),
    path('', include('albums.urls')),
    path('', include('songs.urls')),
    path('', include('playlists.urls')),
]

schema_view = get_schema_view(
    openapi.Info(
        title="SpotifAI API",
        default_version='v1',
        description="API documentation for SpotifAI",
        terms_of_service="https://www.google.com/policies/terms/",
        contact=openapi.Contact(email="prohieu2004@gmail.com"),
        license=openapi.License(name="BSD License"),
    ),
    public=True,
    permission_classes=(permissions.AllowAny,),
)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/v1/', include(api_v1_patterns)),
    path('swagger/', schema_view.with_ui('swagger', cache_timeout=0), name='schema-swagger-ui'),
    path('redoc/', schema_view.with_ui('redoc', cache_timeout=0), name='schema-redoc'),
]
