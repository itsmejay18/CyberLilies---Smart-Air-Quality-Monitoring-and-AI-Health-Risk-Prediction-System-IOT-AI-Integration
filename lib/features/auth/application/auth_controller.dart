import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/app_config.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/repositories/auth_repository.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return SharedPreferences.getInstance();
});

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  final config = ref.watch(appConfigProvider);
  if (!config.isSupabaseConfigured) return null;
  return Supabase.instance.client;
});

final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final client = ref.watch(supabaseClientProvider);
  return AuthRepository(preferences: prefs, supabaseClient: client);
});

final authStateChangesProvider = StreamProvider<UserProfile?>((ref) async* {
  final repository = await ref.watch(authRepositoryProvider.future);
  yield* repository.authStateChanges();
});

final currentUserProvider = FutureProvider<UserProfile?>((ref) async {
  final repository = await ref.watch(authRepositoryProvider.future);
  return repository.currentUser();
});

class AuthController extends AsyncNotifier<void> {
  late final AuthRepository _repository;

  @override
  Future<void> build() async {
    _repository = await ref.watch(authRepositoryProvider.future);
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.signIn(email: email, password: password),
    );
    ref.invalidate(currentUserProvider);
    ref.invalidate(authStateChangesProvider);
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.signUp(
        email: email,
        password: password,
        fullName: fullName,
      ),
    );
    ref.invalidate(currentUserProvider);
    ref.invalidate(authStateChangesProvider);
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.signOut);
    ref.invalidate(currentUserProvider);
    ref.invalidate(authStateChangesProvider);
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);
