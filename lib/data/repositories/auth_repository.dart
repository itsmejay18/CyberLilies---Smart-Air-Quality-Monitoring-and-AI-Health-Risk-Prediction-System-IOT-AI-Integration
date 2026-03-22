import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../models/user_profile.dart';

class AuthRepository {
  AuthRepository({
    required SharedPreferences preferences,
    SupabaseClient? supabaseClient,
  }) : _preferences = preferences,
       _supabaseClient = supabaseClient;

  final SharedPreferences _preferences;
  final SupabaseClient? _supabaseClient;

  Stream<UserProfile?> authStateChanges() {
    if (_supabaseClient != null) {
      return _supabaseClient.auth.onAuthStateChange.asyncMap(
        (_) => currentUser(),
      );
    }

    return Stream<UserProfile?>.periodic(
      const Duration(seconds: 2),
      (_) => _mockUser(),
    ).startWith(_mockUser());
  }

  Future<UserProfile?> currentUser() async {
    if (_supabaseClient != null) {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return null;

      return UserProfile(
        id: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'] as String? ?? 'Farmer',
      );
    }

    return _mockUser();
  }

  Future<void> signIn({required String email, required String password}) async {
    if (_supabaseClient != null) {
      await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return;
    }

    await _preferences.setString(AppConstants.mockSessionPrefsKey, email);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (_supabaseClient != null) {
      await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      return;
    }

    await _preferences.setString(AppConstants.mockSessionPrefsKey, email);
  }

  Future<void> signOut() async {
    if (_supabaseClient != null) {
      await _supabaseClient.auth.signOut();
      return;
    }

    await _preferences.remove(AppConstants.mockSessionPrefsKey);
  }

  UserProfile? _mockUser() {
    final email = _preferences.getString(AppConstants.mockSessionPrefsKey);
    if (email == null || email.isEmpty) return null;

    return UserProfile(
      id: AppConstants.mockUserId,
      email: email,
      fullName: 'Demo Farmer',
    );
  }
}

extension<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
  }
}
