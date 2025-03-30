from django.urls import path
from .views import UserViewSet, CreateUserView

urlpatterns = [
    path('register/', CreateUserView.as_view(), name='register'),
    path('users/', UserViewSet.as_view({'get': 'list', 'post': 'create'}), name='user_list'),
]