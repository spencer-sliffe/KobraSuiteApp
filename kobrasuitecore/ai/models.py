from django.db import models
from django.conf import settings


class ChatLog(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='chat_logs') # Sets foreign key Cell for db
    user_message = models.TextField()
    bot_response = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"ChatLog({self.user.username}, {self.timestamp})"  # String format for chat log object 