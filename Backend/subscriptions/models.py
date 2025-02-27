from django.db import models
from users.models import User

class Subscription(models.Model):
    PLAN_CHOICES = [
        ('FREE', 'Free'),
        ('PREMIUM', 'Premium'),
    ]
    subcription_id = models.AutoField(primary_key=True)
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    plan_type = models.CharField(max_length=10, choices=PLAN_CHOICES)
    start_date = models.DateField(auto_now_add=True)
    expiry_date = models.DateField()

    def __str__(self):
        return f"{self.user.username} - {self.plan_type}"
