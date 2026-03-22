import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/iot_device.dart';
import '../../devices/application/device_providers.dart';

final zoneIoTDeviceProvider = FutureProvider.family<IoTDevice?, String>((
  ref,
  zoneId,
) async {
  final repository = await ref.watch(localDeviceRepositoryProvider.future);
  return repository.loadDeviceForZone(zoneId);
});
