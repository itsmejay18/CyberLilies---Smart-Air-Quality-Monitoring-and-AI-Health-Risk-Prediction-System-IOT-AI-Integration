import 'package:equatable/equatable.dart';

class FarmAlert extends Equatable {
  const FarmAlert({
    required this.id,
    required this.zoneId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String zoneId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  factory FarmAlert.fromMap(Map<String, dynamic> map) {
    return FarmAlert(
      id: map['id'].toString(),
      zoneId: map['zone_id'].toString(),
      title: map['title'] as String? ?? 'Alert',
      message: map['message'] as String? ?? '',
      type: map['type'] as String? ?? 'general',
      isRead: map['is_read'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'zone_id': zoneId,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  FarmAlert copyWith({bool? isRead}) {
    return FarmAlert(
      id: id,
      zoneId: zoneId,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    zoneId,
    title,
    message,
    type,
    isRead,
    createdAt,
  ];
}
