import json
import logging

from django.conf import settings
from django.core.paginator import Paginator
from django.db.models import Avg, Count, OuterRef, Subquery
from django.http import JsonResponse
from django.shortcuts import render
from django.utils import timezone
from django.views.decorators.csrf import csrf_exempt

from .analysis import analyze_telemetry
from .models import TelemetryLog

logger = logging.getLogger('telemetry')


def _check_api_key(request):
    """Return True if auth passes. Skips check when TELEMETRY_API_KEY is not configured."""
    required_key = getattr(settings, 'TELEMETRY_API_KEY', '')
    if not required_key:
        return True
    auth_header = request.META.get('HTTP_AUTHORIZATION', '')
    if auth_header.startswith('Bearer '):
        return auth_header[7:] == required_key
    return False


@csrf_exempt
def ingest_telemetry(request):
    """
    Receives telemetry from agents.

    Supported formats:
      - JSON object (new client format)
      - Pipe-separated JSON chunks (legacy format)

    Optional auth: set TELEMETRY_API_KEY env var and pass
    Authorization: Bearer <key> header.
    """
    if request.method != 'POST':
        return JsonResponse({'error': 'Method not allowed'}, status=405)

    if not _check_api_key(request):
        return JsonResponse({'error': 'Unauthorized'}, status=401)

    try:
        raw_body = request.body.decode('utf-8')
        try:
            payload = json.loads(raw_body)
            parsed_data = {
                'system_info': payload.get('system', {}),
                'cpu_info': payload.get('cpu', {}),
                'memory_info': payload.get('memory', {}),
                'disk_info': payload.get('disks', []),
                'process_info': payload.get('processes', []),
                'network_info': payload.get('network_interfaces', []),
                'users_info': payload.get('users', []),
                'security_info': payload.get('security', {}),
            }
        except json.JSONDecodeError:
            parts = raw_body.split('|')
            if len(parts) < 5:
                return JsonResponse(
                    {'error': 'Invalid format. Expected JSON or 5+ pipe-separated chunks.'},
                    status=400,
                )
            parsed_data = {
                'system_info': json.loads(parts[0]),
                'cpu_info': json.loads(parts[1]),
                'memory_info': json.loads(parts[2]),
                'disk_info': json.loads(parts[3]),
                'process_info': json.loads(parts[4]),
                'network_info': [],
                'users_info': [],
                'security_info': {},
            }

        score, report = analyze_telemetry(parsed_data)
        parsed_data['analysis_report'] = report

        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        ip = x_forwarded_for.split(',')[0].strip() if x_forwarded_for else request.META.get('REMOTE_ADDR')

        hostname = parsed_data['system_info'].get('hostname', 'unknown')
        TelemetryLog.objects.create(
            hostname=hostname,
            ip_address=ip,
            raw_data=raw_body,
            parsed_data=parsed_data,
            risk_score=score,
            analyzed_at=timezone.now(),
        )

        logger.info("Telemetry received from %s (%s) risk_score=%d", hostname, ip, score)
        return JsonResponse({'status': 'success', 'risk_score': score})

    except json.JSONDecodeError:
        return JsonResponse({'error': 'Invalid JSON'}, status=400)
    except Exception as e:
        logger.exception("Error processing telemetry: %s", e)
        return JsonResponse({'error': 'Internal server error'}, status=500)


def dashboard(request):
    """Main dashboard: one row per hostname showing the latest snapshot."""
    # Subquery to get the most recent log id for each hostname
    latest_id_subquery = (
        TelemetryLog.objects.filter(hostname=OuterRef('hostname'))
        .order_by('-timestamp')
        .values('id')[:1]
    )
    latest_logs_qs = (
        TelemetryLog.objects.filter(
            id__in=TelemetryLog.objects.annotate(latest_id=Subquery(latest_id_subquery))
            .values('latest_id')
            .distinct()
        )
        .order_by('-timestamp')
    )

    total_systems = TelemetryLog.objects.values('hostname').distinct().count()
    total_logs = TelemetryLog.objects.count()
    high_risk_count = (
        TelemetryLog.objects.filter(risk_score__gt=50).values('hostname').distinct().count()
    )
    avg_risk = TelemetryLog.objects.aggregate(avg=Avg('risk_score'))['avg'] or 0

    paginator = Paginator(latest_logs_qs, 25)
    page_obj = paginator.get_page(request.GET.get('page'))

    context = {
        'total_systems': total_systems,
        'total_logs': total_logs,
        'high_risk_count': high_risk_count,
        'avg_risk': round(avg_risk, 1),
        'page_obj': page_obj,
        'latest_logs': page_obj.object_list,
    }
    return render(request, 'dashboard.html', context)


def system_detail(request, hostname):
    logs = TelemetryLog.objects.filter(hostname=hostname).order_by('-timestamp')
    paginator = Paginator(logs, 50)
    page_obj = paginator.get_page(request.GET.get('page'))
    return render(
        request,
        'system_detail.html',
        {'hostname': hostname, 'logs': page_obj.object_list, 'page_obj': page_obj},
    )


def api_systems(request):
    """JSON endpoint: latest snapshot per host."""
    latest_id_subquery = (
        TelemetryLog.objects.filter(hostname=OuterRef('hostname'))
        .order_by('-timestamp')
        .values('id')[:1]
    )
    logs = TelemetryLog.objects.filter(
        id__in=TelemetryLog.objects.annotate(latest_id=Subquery(latest_id_subquery))
        .values('latest_id')
        .distinct()
    ).order_by('-timestamp')

    data = [
        {
            'hostname': log.hostname,
            'ip_address': log.ip_address,
            'timestamp': log.timestamp.isoformat(),
            'risk_score': log.risk_score,
            'findings': log.parsed_data.get('analysis_report', []),
        }
        for log in logs
    ]
    return JsonResponse({'systems': data})
