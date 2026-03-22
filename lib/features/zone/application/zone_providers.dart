import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/prediction.dart';
import '../../../data/models/sensor_data_point.dart';
import '../../../data/models/zone_details.dart';
import '../../../data/repositories/farm_repository.dart';
import '../../dashboard/application/dashboard_providers.dart';

final zoneDetailsProvider = FutureProvider.family<ZoneDetails, String>((
  ref,
  zoneId,
) async {
  final repository = ref.watch(farmRepositoryProvider);
  return repository.fetchZoneDetails(zoneId);
});

final zonePredictionProvider = FutureProvider.family<Prediction, String>((
  ref,
  zoneId,
) async {
  final repository = ref.watch(farmRepositoryProvider);
  return repository.fetchPrediction(zoneId);
});

final zoneHistoryProvider = FutureProvider.family
    .autoDispose<
      List<SensorDataPoint>,
      ({String zoneId, AnalyticsRange range})
    >((ref, args) async {
      final repository = ref.watch(farmRepositoryProvider);
      return repository.fetchSensorHistory(args.zoneId, args.range);
    });
