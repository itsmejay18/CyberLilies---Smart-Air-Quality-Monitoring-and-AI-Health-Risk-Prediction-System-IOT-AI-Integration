import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
  });

  final String id;
  final String email;
  final String fullName;

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String? ?? '',
      fullName: map['full_name'] as String? ?? 'Farmer',
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'email': email, 'full_name': fullName};
  }

  @override
  List<Object?> get props => [id, email, fullName];
}
