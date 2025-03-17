"""
------------------Prologue--------------------
File Name: models.py
Path: kobrasuitecore/ai/models.py

Description:
Declares the ChatLog model for storing AI chat interactions, including user messages, bot responses,
and timestamps.

Input:
None directly; models are populated by the application’s services and views.

Output:
Database tables representing chat logs.

Collaborators: SPENCER SLIFFE
---------------------------------------------
"""
# ai/models.py

from django.db import models
from django.conf import settings

# Makes The Chat log table model for the dbb
class ChatLog(models.Model):  
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='chat_logs') # Sets foreign key Cell for db
    user_message = models.TextField()
    bot_response = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"ChatLog({self.user.username}, {self.timestamp})"  # String format for chat log object 