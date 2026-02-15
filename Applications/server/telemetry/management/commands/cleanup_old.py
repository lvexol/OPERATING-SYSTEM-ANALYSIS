from django.core.management.base import BaseCommand
from django.utils import timezone
from datetime import timedelta
from telemetry.models import TelemetryLog

class Command(BaseCommand):
    help = 'Deletes telemetry logs older than X days (default 30)'

    def add_arguments(self, parser):
        parser.add_argument('--days', type=int, default=30)

    def handle(self, *args, **options):
        days = options['days']
        cutoff = timezone.now() - timedelta(days=days)
        deleted_count, _ = TelemetryLog.objects.filter(timestamp__lt=cutoff).delete()
        
        self.stdout.write(self.style.SUCCESS(f"Deleted {deleted_count} logs older than {days} days"))
