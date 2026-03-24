import '../../data/models/prediction.dart';
import '../../data/models/zone.dart';

String plantTranslatorMessage({
  required Zone zone,
  required Prediction prediction,
}) {
  final forecastHours = prediction.forecastHours;
  final probability = (prediction.stressProbability * 100).round();

  if (prediction.stressLevel == StressLevel.healthy) {
    return 'Air quality conditions are stable in ${zone.name}. Current respiratory risk remains low.';
  }

  if (prediction.stressLevel == StressLevel.warning) {
    return 'Conditions in ${zone.name} are changing. Sensitive users should reduce exposure if needed.';
  }

  if (prediction.stressLevel == StressLevel.critical) {
    return 'Elevated respiratory risk predicted within $forecastHours hours. Estimated risk is $probability%.';
  }

  return 'AIRA recommends monitoring ${zone.name} closely over the next $forecastHours hours.';
}
