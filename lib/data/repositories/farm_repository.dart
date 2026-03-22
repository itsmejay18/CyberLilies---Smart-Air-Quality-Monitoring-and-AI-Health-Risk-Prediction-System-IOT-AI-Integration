import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/farm_action.dart';
import '../models/farm_alert.dart';
import '../models/iot_device.dart';
import '../models/prediction.dart';
import '../models/sensor_data_point.dart';
import '../models/zone.dart';
import '../models/zone_details.dart';
import '../services/ai_api_service.dart';

enum AnalyticsRange {
  last24Hours('24h', 24),
  last7Days('7d', 7 * 24),
  last30Days('30d', 30 * 24);

  const AnalyticsRange(this.label, this.hours);
  final String label;
  final int hours;
}

class FarmRepository {
  FarmRepository({
    required AiApiService aiApiService,
    SupabaseClient? supabaseClient,
  }) : _aiApiService = aiApiService,
       _supabaseClient = supabaseClient;

  final AiApiService _aiApiService;
  final SupabaseClient? _supabaseClient;

  Future<List<Zone>> fetchZones() async {
    final client = _supabaseClient;
    if (client == null) return const [];

    try {
      final zoneRows = await client.from('zones').select();
      final zones = (zoneRows as List<dynamic>)
          .map((item) => Zone.fromMap(item as Map<String, dynamic>))
          .toList();
      return Future.wait(zones.map(_enrichZone));
    } catch (_) {
      return const [];
    }
  }

  Stream<List<Zone>> watchZones() async* {
    yield await fetchZones();
    yield* Stream<void>.periodic(
      const Duration(seconds: 10),
    ).asyncMap((_) => fetchZones());
  }

  Future<ZoneDetails> fetchZoneDetails(String zoneId) async {
    final zones = await fetchZones();
    final zone = zones.firstWhere((item) => item.id == zoneId);
    final history = await fetchSensorHistory(zoneId, AnalyticsRange.last24Hours);
    final prediction = await fetchPrediction(zoneId);
    final action = await fetchLastAction(zoneId);

    return ZoneDetails(
      zone: zone,
      latestSensorData: history.isNotEmpty ? history.first : null,
      prediction: prediction,
      lastAction: action,
    );
  }

  Future<List<SensorDataPoint>> fetchSensorHistory(
    String zoneId,
    AnalyticsRange range,
  ) async {
    final client = _supabaseClient;
    if (client == null) return const [];

    try {
      final start = DateTime.now()
          .subtract(Duration(hours: range.hours))
          .toIso8601String();
      final response = await client
          .from('sensor_data')
          .select()
          .eq('zone_id', zoneId)
          .gte('recorded_at', start)
          .order('recorded_at', ascending: false);

      return (response as List<dynamic>)
          .map((item) => SensorDataPoint.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<Prediction?> fetchPrediction(String zoneId) async {
    try {
      return await _aiApiService.fetchPrediction(zoneId);
    } catch (_) {
      final client = _supabaseClient;
      if (client == null) return null;

      try {
        final response = await client
            .from('predictions')
            .select()
            .eq('zone_id', zoneId)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        if (response != null) {
          return Prediction.fromMap(response);
        }
      } catch (_) {}

      return null;
    }
  }

  Future<List<FarmAlert>> fetchAlerts() async {
    final client = _supabaseClient;
    if (client != null) {
      try {
        final response = await client
            .from('alerts')
            .select()
            .order('created_at', ascending: false);

        return (response as List<dynamic>)
            .map((item) => FarmAlert.fromMap(item as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    try {
      return await _aiApiService.fetchAlerts();
    } catch (_) {
      return const [];
    }
  }

  Stream<List<FarmAlert>> watchAlerts() async* {
    yield await fetchAlerts();
    yield* Stream<void>.periodic(
      const Duration(seconds: 12),
    ).asyncMap((_) => fetchAlerts());
  }

  Future<void> markAlertsRead(List<FarmAlert> alerts) async {
    final client = _supabaseClient;
    if (client == null) return;

    try {
      for (final alert in alerts.where((item) => !item.isRead)) {
        await client.from('alerts').update({'is_read': true}).eq('id', alert.id);
      }
    } catch (_) {}
  }

  Future<FarmAction> triggerManualIrrigation(String zoneId) async {
    try {
      final action = await _aiApiService.actuate(
        zoneId: zoneId,
        action: 'manual_irrigation',
      );

      final client = _supabaseClient;
      if (client != null) {
        try {
          await client.from('actions').insert(action.toMap());
        } catch (_) {}
      }

      return action;
    } catch (_) {
      return FarmAction(
        id: 'manual-irrigation-unavailable',
        zoneId: zoneId,
        actionType: 'manual_irrigation',
        status: 'failed',
        createdAt: DateTime.now(),
        notes:
            'Irrigation command was not sent because the backend is unavailable.',
      );
    }
  }

  Future<FarmAction?> fetchLastAction(String zoneId) async {
    final client = _supabaseClient;
    if (client == null) return null;

    try {
      final response = await client
          .from('actions')
          .select()
          .eq('zone_id', zoneId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return FarmAction.fromMap(response);
      }
    } catch (_) {}

    return null;
  }

  Future<List<IoTDevice>> fetchIoTDevices() async {
    final client = _supabaseClient;
    if (client == null) return const [];

    try {
      final response = await client
          .from('iot_devices')
          .select()
          .order('last_seen', ascending: false);

      return (response as List<dynamic>)
          .map((item) => IoTDevice.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Stream<List<IoTDevice>> watchIoTDevices() async* {
    yield await fetchIoTDevices();
    yield* Stream<void>.periodic(
      const Duration(seconds: 15),
    ).asyncMap((_) => fetchIoTDevices());
  }

  Future<IoTDevice?> fetchDeviceForZone(String zoneId) async {
    final devices = await fetchIoTDevices();
    for (final device in devices) {
      if (device.zoneId == zoneId) {
        return device;
      }
    }
    return null;
  }

  Future<void> registerDevice({
    required String deviceId,
    required String zoneId,
    required String deviceName,
  }) async {
    final client = _supabaseClient;
    if (client == null) {
      throw StateError('Supabase is not configured for this build.');
    }

    await client.from('iot_devices').upsert({
      'id': deviceId,
      'zone_id': zoneId,
      'name': deviceName,
      'connection_state': 'offline',
      'last_seen': DateTime.now().toIso8601String(),
      'battery_level': 100,
      'signal_strength': 0,
      'firmware_version': 'pending-device-sync',
      'pump_online': false,
      'pending_sync': true,
    });
  }

  Future<Zone> _enrichZone(Zone zone) async {
    final history = await fetchSensorHistory(zone.id, AnalyticsRange.last24Hours);
    final prediction = await fetchPrediction(zone.id);
    final latest = history.isNotEmpty ? history.first : null;

    return zone.copyWith(
      soilMoisture: latest?.soilMoisture ?? zone.soilMoisture,
      temperature: latest?.temperature ?? zone.temperature,
      humidity: latest?.humidity ?? zone.humidity,
      predictedStress: prediction?.stressLevel ?? zone.predictedStress,
    );
  }
}
