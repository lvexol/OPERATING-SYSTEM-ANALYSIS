from django.urls import path
from django.views.generic import RedirectView
from . import views

urlpatterns = [
    path('', RedirectView.as_view(pattern_name='dashboard', permanent=False)),
    # Telemetry ingest (both path variants kept for backwards-compat)
    path('api/telemetry/', views.ingest_telemetry, name='ingest'),
    path('api/v1/telemetry/', views.ingest_telemetry, name='ingest_v1'),
    # JSON API
    path('api/v1/systems/', views.api_systems, name='api_systems'),
    # Dashboard UI
    path('dashboard/', views.dashboard, name='dashboard'),
    path('system/<str:hostname>/', views.system_detail, name='system_detail'),
]
