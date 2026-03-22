import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/iot_device.dart';
import '../../../data/repositories/local_device_repository.dart';
import '../../auth/application/auth_controller.dart';

final localDeviceRepositoryProvider = FutureProvider<LocalDeviceRepository>((
  ref,
) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return LocalDeviceRepository(preferences: prefs);
});

final iotDevicesProvider = FutureProvider<List<IoTDevice>>((ref) async {
  final repository = await ref.watch(localDeviceRepositoryProvider.future);
  return repository.loadDevices();
});
