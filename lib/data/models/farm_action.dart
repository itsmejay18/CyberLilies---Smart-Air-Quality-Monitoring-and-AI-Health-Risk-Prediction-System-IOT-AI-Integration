import 'package:equatable/equatable.dart';

class FarmAction extends Equatable {
  const FarmAction({
    required this.id,
    required this.zoneId,
    required this.actionType,
    required this.status,
    required this.createdAt,
    required this.notes,
  });

  final String id;
  final String zoneId;
  final String actionType;
  final String status;
  final DateTime createdAt;
  final String notes;

  factory FarmAction.fromMap(Map<String, dynamic> map) {
    return FarmAction(
      id: map['id'].toString(),
      zoneId: map['zone_id'].toString(),
      actionType: map['action_type'] as String? ?? 'irrigation',
      status: map['status'] as String? ?? 'completed',
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      notes: map['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'zone_id': zoneId,
      'action_type': actionType,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'notes': notes,
    };
  }

  @override
  List<Object?> get props => [id, zoneId, actionType, status, createdAt, notes];
}
