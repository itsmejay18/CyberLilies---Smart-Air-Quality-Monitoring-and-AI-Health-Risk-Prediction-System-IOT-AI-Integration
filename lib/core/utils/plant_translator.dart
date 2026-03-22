import '../../data/models/prediction.dart';
import '../../data/models/zone.dart';

String plantTranslatorMessage({
  required Zone zone,
  required Prediction prediction,
}) {
  final moisture = zone.soilMoisture;
  final forecastHours = prediction.forecastHours;
  final probability = (prediction.stressProbability * 100).round();

  if (prediction.stressLevel == StressLevel.healthy && moisture >= 55) {
    return 'Your plant is healthy. Soil moisture is stable in ${zone.name}.';
  }

  if (prediction.stressLevel == StressLevel.warning && moisture < 45) {
    return 'Warning: Soil moisture is dropping. ${zone.name} may need water soon.';
  }

  if (prediction.stressLevel == StressLevel.critical) {
    return 'High risk of drought stress in $forecastHours hours. Estimated risk is $probability%.';
  }

  return 'Conditions are changing. Monitor ${zone.name} over the next $forecastHours hours.';
}
