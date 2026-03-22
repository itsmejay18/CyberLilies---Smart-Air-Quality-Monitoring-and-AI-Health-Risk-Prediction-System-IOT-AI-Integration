import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_settings.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../auth/application/auth_controller.dart';

final settingsRepositoryProvider = FutureProvider<SettingsRepository>((
  ref,
) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final client = ref.watch(supabaseClientProvider);
  return SettingsRepository(preferences: prefs, supabaseClient: client);
});

final settingsProvider = FutureProvider<AppSettings>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  final repository = await ref.watch(settingsRepositoryProvider.future);

  return repository.loadSettings(
    userId: user?.id ?? 'guest',
    email: user?.email ?? 'guest@demo.com',
  );
});

class SettingsController extends AsyncNotifier<void> {
  late final SettingsRepository _repository;

  @override
  Future<void> build() async {
    _repository = await ref.watch(settingsRepositoryProvider.future);
  }

  Future<void> updateSettings(AppSettings settings) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.saveSettings(settings));
    ref.invalidate(settingsProvider);
  }
}

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, void>(SettingsController.new);
