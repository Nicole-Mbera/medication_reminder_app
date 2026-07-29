import 'package:equatable/equatable.dart';

class DoseLogModel extends Equatable {
  final String id;
  final String medicationId;
  final String medicationName;
  final String userId;
  final DateTime scheduledTime;
  final String status; // 'taken', 'missed', 'skipped'
  final DateTime loggedAt;

  const DoseLogModel({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.userId,
    required this.scheduledTime,
    required this.status,
    required this.loggedAt,
  });

  factory DoseLogModel.fromMap(Map<String, dynamic> map, String docId) {
    return DoseLogModel(
      id: docId,
      medicationId: map['medicationId'] ?? '',
      medicationName: map['medicationName'] ?? '',
      userId: map['userId'] ?? '',
      scheduledTime: map['scheduledTime'] != null
          ? DateTime.parse(map['scheduledTime'])
          : DateTime.now(),
      status: map['status'] ?? 'taken',
      loggedAt: map['loggedAt'] != null
          ? DateTime.parse(map['loggedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'userId': userId,
      'scheduledTime': scheduledTime.toIso8601String(),
      'status': status,
      'loggedAt': loggedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    medicationId,
    medicationName,
    userId,
    scheduledTime,
    status,
    loggedAt,
  ];
}
