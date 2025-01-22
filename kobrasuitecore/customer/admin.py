from django.contrib import admin
from .models import User, Role, MFAConfig, UserProfile, SecureDocument


@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ('username', 'email', 'is_email_verified', 'is_phone_verified', 'is_staff', 'is_superuser')
    search_fields = ('username', 'email')
    list_filter = ('is_email_verified', 'is_phone_verified', 'is_staff', 'is_superuser')


@admin.register(Role)
class RoleAdmin(admin.ModelAdmin):
    list_display = ('name', 'description')
    filter_horizontal = ('permissions', 'users',)
    search_fields = ('name',)


@admin.register(MFAConfig)
class MFAConfigAdmin(admin.ModelAdmin):
    list_display = ('user', 'mfa_enabled', 'mfa_type', 'secret_key')
    search_fields = ('user__username',)


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'date_of_birth')
    search_fields = ('user__username',)


@admin.register(SecureDocument)
class SecureDocumentAdmin(admin.ModelAdmin):
    list_display = ('title', 'user', 'created_at')
    search_fields = ('title', 'user__username')
    list_filter = ('created_at',)
