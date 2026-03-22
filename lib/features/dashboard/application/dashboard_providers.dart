import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_config.dart';
import '../../../data/models/zone.dart';
import '../../../data/repositories/farm_repository.dart';
import '../../../data/services/ai_api_service.dart';
import '../../auth/application/auth_controller.dart';

final aiApiServiceProvider = Provider<AiApiService>((ref) {
  final config = ref.watch(appConfigProvider);
  return AiApiService(config);
});

final farmRepositoryProvider = Provider<FarmRepository>((ref) {
  final api = ref.watch(aiApiServiceProvider);
  final client = ref.watch(supabaseClientProvider);
  return FarmRepository(aiApiService: api, supabaseClient: client);
});

final zonesProvider = StreamProvider<List<Zone>>((ref) {
  final repository = ref.watch(farmRepositoryProvider);
  return repository.watchZones();
});
