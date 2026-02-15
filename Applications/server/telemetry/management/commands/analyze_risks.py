from django.core.management.base import BaseCommand
from django.utils import timezone
from telemetry.models import TelemetryLog
from telemetry.analysis import analyze_telemetry

class Command(BaseCommand):
    help = 'Analyzes un-analyzed telemetry logs for risks'

    def handle(self, *args, **options):
        logs = TelemetryLog.objects.filter(analyzed_at__isnull=True)
        count = logs.count()
        self.stdout.write(f"Found {count} un-analyzed logs...")

        for log in logs:
            score, report = analyze_telemetry(log.parsed_data)
            log.risk_score = score
            log.parsed_data['analysis_report'] = report
            log.analyzed_at = timezone.now()
            log.save()
            
        self.stdout.write(self.style.SUCCESS(f"Successfully analyzed {count} logs"))
