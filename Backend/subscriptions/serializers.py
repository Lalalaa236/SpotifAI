from rest_framework import serializers
from .models import Subscription

class SubscriptionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Subscription
        fields = ['subcription_id', 'user', 'plan_type', 'start_date', 'expiry_date']