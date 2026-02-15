import json
from django.shortcuts import render
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.utils import timezone
from .models import TelemetryLog
from .analysis import analyze_telemetry

@csrf_exempt
def ingest_telemetry(request):
    """
    Receives pipe-separated JSON objects.
    Format:
    {"sys_info"...} | {"cpu_info"...} | {"mem_info"...} | [{"disk"...}] | [{"proc"...}]
    """
    if request.method != 'POST':
        return JsonResponse({'error': 'Method not allowed'}, status=405)

    try:
        raw_body = request.body.decode('utf-8')
        try:
            # Attempt to parse as a single JSON object (New Client Format)
            payload = json.loads(raw_body)
            parsed_data = {
                'system_info': payload.get('system', {}),
                'cpu_info': payload.get('cpu', {}),
                'memory_info': payload.get('memory', {}),
                'disk_info': payload.get('disks', []),
                'process_info': payload.get('processes', [])
            }
        except json.JSONDecodeError:
            # Fallback to pipe-separated format (Legacy)
            parts = raw_body.split('|')
            
            if len(parts) < 5:
                 return JsonResponse({'error': 'Invalid format. Expected JSON or 5 pipe-separated chunks.'}, status=400)
    
            parsed_data = {
                'system_info': json.loads(parts[0]),
                'cpu_info': json.loads(parts[1]),
                'memory_info': json.loads(parts[2]),
                'disk_info': json.loads(parts[3]),
                'process_info': json.loads(parts[4])
            }

        # Analyze
        score, report = analyze_telemetry(parsed_data)
        parsed_data['analysis_report'] = report

        # Get IP
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0]
        else:
            ip = request.META.get('REMOTE_ADDR')

        # Save
        TelemetryLog.objects.create(
            hostname=parsed_data['system_info'].get('hostname', 'unknown'),
            ip_address=ip,
            raw_data=raw_body,
            parsed_data=parsed_data,
            risk_score=score,
            analyzed_at=timezone.now()
        )

        return JsonResponse({'status': 'success', 'risk_score': score})

    except json.JSONDecodeError:
        return JsonResponse({'error': 'Invalid JSON'}, status=400)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

def dashboard(request):
    """
    Principal Dashboard View
    """
    total_systems = TelemetryLog.objects.values('hostname').distinct().count()
    high_risk_count = TelemetryLog.objects.filter(risk_score__gt=50).values('hostname').distinct().count()
    
    # Get latest log for each host
    # This is a bit complex in standard SQL, simpler in Python for MVP or use Postgres DISTINCT ON
    # For now, just get latest 50 logs
    latest_logs = TelemetryLog.objects.all()[:20]

    context = {
        'total_systems': total_systems,
        'high_risk_count': high_risk_count,
        'latest_logs': latest_logs
    }
    return render(request, 'dashboard.html', context)

def system_detail(request, hostname):
    logs = TelemetryLog.objects.filter(hostname=hostname).order_by('-timestamp')[:50]
    return render(request, 'system_detail.html', {'hostname': hostname, 'logs': logs})
