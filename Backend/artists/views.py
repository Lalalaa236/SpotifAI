from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import action

from .models import Artist
from .serializers import ArtistSerializer


class ArtistViewSet(viewsets.ModelViewSet):
    queryset = Artist.objects.all()
    serializer_class = ArtistSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    @action(detail=False, methods=['get'])
    def find_artist(self, request):
        query = request.query_params.get('q', '')
        if not query:
            return Response(
                {"error": "Please provide a query parameter 'q' to search for an artist."},
                status=status.HTTP_400_BAD_REQUEST
            )
         
        artists = Artist.objects.filter(name__icontains=query)
        serializer = self.get_serializer(artists, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
