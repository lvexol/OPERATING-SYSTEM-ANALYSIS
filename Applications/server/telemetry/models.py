from django.db import models
from django.utils import timezone

class TelemetryLog(models.Model):
    timestamp = models.DateTimeField(db_index=True, default=timezone.now)
    hostname = models.CharField(max_length=255, db_index=True)
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    
    # Raw pipe-separated string for archival/audit
    raw_data = models.TextField()
    
    # Structured data for querying
    parsed_data = models.JSONField(default=dict)
    
    # Analysis results
    risk_score = models.IntegerField(default=0, help_text="0-100 score based on risk analysis")
    analyzed_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        ordering = ['-timestamp']
        indexes = [
            models.Index(fields=['hostname', 'timestamp']),
            models.Index(fields=['risk_score']),
        ]

    def __str__(self):
        return f"{self.hostname} @ {self.timestamp} (Risk: {self.risk_score})"
