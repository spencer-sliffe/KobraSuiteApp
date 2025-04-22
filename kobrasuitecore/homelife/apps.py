from django.apps import AppConfig


class HomelifeConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'homelife'

    def ready(self):
        import homelife.signals.calendar_sync  # noqa: F401
