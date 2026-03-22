import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/farm_repository.dart';

class AnalyticsRangeNotifier extends Notifier<AnalyticsRange> {
  @override
  AnalyticsRange build() => AnalyticsRange.last24Hours;

  void setRange(AnalyticsRange range) => state = range;
}

class AnalyticsSelectedZoneNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setZone(String? zoneId) => state = zoneId;
}

final analyticsRangeProvider =
    NotifierProvider<AnalyticsRangeNotifier, AnalyticsRange>(
      AnalyticsRangeNotifier.new,
    );

final analyticsSelectedZoneIdProvider =
    NotifierProvider<AnalyticsSelectedZoneNotifier, String?>(
      AnalyticsSelectedZoneNotifier.new,
    );
