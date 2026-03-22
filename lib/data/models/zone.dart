import 'package:equatable/equatable.dart';

enum StressLevel { healthy, warning, critical }

class Zone extends Equatable {
  const Zone({
    required this.id,
    required this.name,
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
    required this.currentStress,
    required this.predictedStress,
    required this.autoIrrigationEnabled,
  });

  final String id;
  final String name;
  final double soilMoisture;
  final double temperature;
  final double humidity;
  final StressLevel currentStress;
  final StressLevel predictedStress;
  final bool autoIrrigationEnabled;

  factory Zone.fromMap(Map<String, dynamic> map) {
    return Zone(
      id: map['id'].toString(),
      name: map['name'] as String? ?? 'Zone',
      soilMoisture: (map['soil_moisture'] as num?)?.toDouble() ?? 0,
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0,
      humidity: (map['humidity'] as num?)?.toDouble() ?? 0,
      currentStress: _levelFromString(map['current_stress'] as String?),
      predictedStress: _levelFromString(map['predicted_stress'] as String?),
      autoIrrigationEnabled: map['auto_irrigation_enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'soil_moisture': soilMoisture,
      'temperature': temperature,
      'humidity': humidity,
      'current_stress': currentStress.name,
      'predicted_stress': predictedStress.name,
      'auto_irrigation_enabled': autoIrrigationEnabled,
    };
  }

  Zone copyWith({
    double? soilMoisture,
    double? temperature,
    double? humidity,
    StressLevel? currentStress,
    StressLevel? predictedStress,
    bool? autoIrrigationEnabled,
  }) {
    return Zone(
      id: id,
      name: name,
      soilMoisture: soilMoisture ?? this.soilMoisture,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      currentStress: currentStress ?? this.currentStress,
      predictedStress: predictedStress ?? this.predictedStress,
      autoIrrigationEnabled:
          autoIrrigationEnabled ?? this.autoIrrigationEnabled,
    );
  }

  static StressLevel _levelFromString(String? value) {
    return StressLevel.values.firstWhere(
      (element) => element.name == value,
      orElse: () => StressLevel.healthy,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    soilMoisture,
    temperature,
    humidity,
    currentStress,
    predictedStress,
    autoIrrigationEnabled,
  ];
}
