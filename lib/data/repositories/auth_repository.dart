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

      try {
        final profile = await _supabaseClient
            .from('users')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (profile != null) {
          return UserProfile.fromMap({
            'id': user.id,
            'email': user.email,
            ...profile,
          });
        }
      } catch (_) {
        // Fall back to the auth profile when the users table is not ready.
      }

      return _supabaseUserToProfile(user);
    }

    return _mockUser();
  }

  Future<void> signIn({required String email, required String password}) async {
    if (_supabaseClient != null) {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      await _syncSupabaseProfile(response.user, fallbackFullName: 'AIRA User');
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
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      await _syncSupabaseProfile(response.user, fallbackFullName: fullName);
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
      fullName: 'AIRA User',
    );
  }

  UserProfile _supabaseUserToProfile(User user) {
    return UserProfile(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String? ?? 'AIRA User',
    );
  }

  Future<void> _syncSupabaseProfile(
    User? user, {
    required String fallbackFullName,
  }) async {
    final client = _supabaseClient;
    if (client == null || user == null) return;

    try {
      await client.from('users').upsert({
        'id': user.id,
        'email': user.email ?? '',
        'full_name':
            user.userMetadata?['full_name'] as String? ?? fallbackFullName,
      });
    } catch (_) {
      // Ignore until the users table exists.
    }
  }
}

extension<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
  }
}
