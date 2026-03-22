import 'package:equatable/equatable.dart';

class SensorDataPoint extends Equatable {
  const SensorDataPoint({
    required this.id,
    required this.zoneId,
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
    required this.recordedAt,
  });

  final String id;
  final String zoneId;
  final double soilMoisture;
  final double temperature;
  final double humidity;
  final DateTime recordedAt;

  factory SensorDataPoint.fromMap(Map<String, dynamic> map) {
    return SensorDataPoint(
      id: map['id'].toString(),
      zoneId: map['zone_id'].toString(),
      soilMoisture: (map['soil_moisture'] as num?)?.toDouble() ?? 0,
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0,
      humidity: (map['humidity'] as num?)?.toDouble() ?? 0,
      recordedAt: DateTime.parse(map['recorded_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'zone_id': zoneId,
      'soil_moisture': soilMoisture,
      'temperature': temperature,
      'humidity': humidity,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    zoneId,
    soilMoisture,
    temperature,
    humidity,
    recordedAt,
  ];
}
