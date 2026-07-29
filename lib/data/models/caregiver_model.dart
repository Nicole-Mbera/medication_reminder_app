import 'package:equatable/equatable.dart';

class CaregiverModel extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String relationship; // 'Daughter', 'Primary Physician', etc.
  final String email;
  final String status; // 'Connected', 'Pending Invite'
  final DateTime createdAt;

  const CaregiverModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.relationship,
    required this.email,
    required this.status,
    required this.createdAt,
  });

  factory CaregiverModel.fromMap(Map<String, dynamic> map, String docId) {
    return CaregiverModel(
      id: docId,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      relationship: map['relationship'] ?? '',
      email: map['email'] ?? '',
      status: map['status'] ?? 'Connected',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'relationship': relationship,
      'email': email,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    relationship,
    email,
    status,
    createdAt,
  ];
}
