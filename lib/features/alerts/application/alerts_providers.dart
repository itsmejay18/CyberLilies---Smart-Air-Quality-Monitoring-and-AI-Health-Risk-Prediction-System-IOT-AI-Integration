import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/farm_alert.dart';
import '../../dashboard/application/dashboard_providers.dart';

final alertsProvider = StreamProvider<List<FarmAlert>>((ref) {
  final repository = ref.watch(farmRepositoryProvider);
  return repository.watchAlerts();
});

final unreadAlertsCountProvider = Provider<int>((ref) {
  final alerts = ref.watch(alertsProvider).asData?.value ?? const <FarmAlert>[];
  return alerts.where((item) => !item.isRead).length;
});
