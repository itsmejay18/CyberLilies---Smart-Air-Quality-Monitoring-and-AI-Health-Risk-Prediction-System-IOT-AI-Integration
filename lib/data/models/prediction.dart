import 'package:equatable/equatable.dart';

import 'zone.dart';

class Prediction extends Equatable {
  const Prediction({
    required this.zoneId,
    required this.stressProbability,
    required this.stressLevel,
    required this.forecastHours,
    required this.summary,
    required this.createdAt,
  });

  final String zoneId;
  final double stressProbability;
  final StressLevel stressLevel;
  final int forecastHours;
  final String summary;
  final DateTime createdAt;

  factory Prediction.fromMap(Map<String, dynamic> map) {
    return Prediction(
      zoneId: map['zone_id'].toString(),
      stressProbability: (map['stress_probability'] as num?)?.toDouble() ?? 0,
      stressLevel: StressLevel.values.firstWhere(
        (item) => item.name == (map['stress_level'] as String?),
        orElse: () => StressLevel.healthy,
      ),
      forecastHours: map['forecast_hours'] as int? ?? 4,
      summary: map['summary'] as String? ?? 'Conditions stable.',
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'zone_id': zoneId,
      'stress_probability': stressProbability,
      'stress_level': stressLevel.name,
      'forecast_hours': forecastHours,
      'summary': summary,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    zoneId,
    stressProbability,
    stressLevel,
    forecastHours,
    summary,
    createdAt,
  ];
}
