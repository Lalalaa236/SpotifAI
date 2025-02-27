from django.shortcuts import render
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Subscription
from .serializers import SubscriptionSerializer
from datetime import datetime, timedelta

class SubscriptionViewSet(viewsets.ModelViewSet):
    queryset = Subscription.objects.all()
    serializer_class = SubscriptionSerializer

    @action(detail=False, methods=['post'])
    def subscribe(self, request):
        user_id = request.data.get('user_id')
        plan_type = request.data.get('plan_type')

        if not all([user_id, plan_type]):
            return Response({
                "status": "failed",
                "message": "Missing required fields"
            }, status=status.HTTP_400_BAD_REQUEST)

        expiry_date = datetime.now() + timedelta(days=30)
        subscription = Subscription.objects.create(
            user_id=user_id,
            plan_type=plan_type,
            expiry_date=expiry_date
        )
        serializer = SubscriptionSerializer(subscription)

        return Response({
            "status": "success",
            "data": serializer.data
        })

    @action(detail=True, methods=['post'])
    def renew(self, request, pk=None):
        subscription = self.get_object()
        subscription.expiry_date = datetime.now() + timedelta(days=30)
        subscription.save()
        serializer = SubscriptionSerializer(subscription)

        return Response({
            "status": "success",
            "data": serializer.data
        })
