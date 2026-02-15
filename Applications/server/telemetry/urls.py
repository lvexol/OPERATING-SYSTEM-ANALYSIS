from django.urls import path
from django.views.generic import RedirectView
from . import views

urlpatterns = [
    path('', RedirectView.as_view(pattern_name='dashboard', permanent=False)),
    path('api/telemetry/', views.ingest_telemetry, name='ingest'),
    path('api/v1/telemetry/', views.ingest_telemetry, name='ingest_v1'),
    path('dashboard/', views.dashboard, name='dashboard'),
    path('system/<str:hostname>/', views.system_detail, name='system_detail'),
]
