from django.contrib import admin
from .models import TelemetryLog

@admin.register(TelemetryLog)
class TelemetryLogAdmin(admin.ModelAdmin):
    list_display = ('hostname', 'ip_address', 'timestamp', 'risk_score', 'analyzed_at')
    list_filter = ('hostname', 'risk_score')
    search_fields = ('hostname', 'ip_address', 'raw_data')
    readonly_fields = ('timestamp', 'analyzed_at')
    ordering = ('-timestamp',)
