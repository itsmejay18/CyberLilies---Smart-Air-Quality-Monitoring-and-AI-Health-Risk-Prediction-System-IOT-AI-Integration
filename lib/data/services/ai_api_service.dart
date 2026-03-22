import 'package:dio/dio.dart';

import '../../core/utils/app_config.dart';
import '../models/farm_action.dart';
import '../models/farm_alert.dart';
import '../models/prediction.dart';

class AiApiService {
  AiApiService(AppConfig config)
    : _dio = Dio(
        BaseOptions(
          baseUrl: config.aiBaseUrl,
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

  final Dio _dio;

  Future<void> postSensorData(Map<String, dynamic> payload) async {
    await _dio.post('/sensor-data', data: payload);
  }

  Future<Prediction> fetchPrediction(String zoneId) async {
    final response = await _dio.get('/prediction/$zoneId');
    return Prediction.fromMap(response.data as Map<String, dynamic>);
  }

  Future<FarmAction> actuate({
    required String zoneId,
    required String action,
  }) async {
    final response = await _dio.post(
      '/actuate',
      data: {'zone_id': zoneId, 'action': action},
    );

    return FarmAction.fromMap(response.data as Map<String, dynamic>);
  }

  Future<List<FarmAlert>> fetchAlerts() async {
    final response = await _dio.get('/alerts');
    final data = response.data as List<dynamic>;
    return data
        .map((item) => FarmAlert.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}
