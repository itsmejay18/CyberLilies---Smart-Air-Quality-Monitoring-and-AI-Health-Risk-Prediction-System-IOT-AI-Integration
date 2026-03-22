import 'package:equatable/equatable.dart';

import 'farm_action.dart';
import 'prediction.dart';
import 'sensor_data_point.dart';
import 'zone.dart';

class ZoneDetails extends Equatable {
  const ZoneDetails({
    required this.zone,
    required this.latestSensorData,
    required this.prediction,
    required this.lastAction,
  });

  final Zone zone;
  final SensorDataPoint? latestSensorData;
  final Prediction? prediction;
  final FarmAction? lastAction;

  @override
  List<Object?> get props => [zone, latestSensorData, prediction, lastAction];
}
