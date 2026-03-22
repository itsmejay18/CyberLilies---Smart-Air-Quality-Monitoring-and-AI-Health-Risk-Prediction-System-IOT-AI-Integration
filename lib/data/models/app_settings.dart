import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  const AppSettings({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.autoIrrigationEnabled,
    required this.notificationsEnabled,
  });

  final String userId;
  final String fullName;
  final String email;
  final bool autoIrrigationEnabled;
  final bool notificationsEnabled;

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      userId: map['user_id'] as String? ?? '',
      fullName: map['full_name'] as String? ?? 'Farmer',
      email: map['email'] as String? ?? '',
      autoIrrigationEnabled: map['auto_irrigation_enabled'] as bool? ?? true,
      notificationsEnabled: map['notifications_enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'auto_irrigation_enabled': autoIrrigationEnabled,
      'notifications_enabled': notificationsEnabled,
    };
  }

  AppSettings copyWith({
    String? fullName,
    String? email,
    bool? autoIrrigationEnabled,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      userId: userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      autoIrrigationEnabled:
          autoIrrigationEnabled ?? this.autoIrrigationEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    fullName,
    email,
    autoIrrigationEnabled,
    notificationsEnabled,
  ];
}
