import 'package:equatable/equatable.dart';

class MedicationModel extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final String frequency; // 'Daily', 'As Needed', 'Specific Days'
  final List<String> times; // e.g. ["08:00", "20:00"]
  final String instructions; // e.g. "Take with food"
  final String? photoUrl;
  final int inventoryCount;
  final DateTime createdAt;

  const MedicationModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.times,
    required this.instructions,
    this.photoUrl,
    required this.inventoryCount,
    required this.createdAt,
  });

  factory MedicationModel.fromMap(Map<String, dynamic> map, String docId) {
    return MedicationModel(
      id: docId,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? 'Daily',
      times: List<String>.from(map['times'] ?? []),
      instructions: map['instructions'] ?? '',
      photoUrl: map['photoUrl'],
      inventoryCount: (map['inventoryCount'] ?? 30) as int,
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
      'dosage': dosage,
      'frequency': frequency,
      'times': times,
      'instructions': instructions,
      'photoUrl': photoUrl,
      'inventoryCount': inventoryCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  MedicationModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? dosage,
    String? frequency,
    List<String>? times,
    String? instructions,
    String? photoUrl,
    int? inventoryCount,
    DateTime? createdAt,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      times: times ?? this.times,
      instructions: instructions ?? this.instructions,
      photoUrl: photoUrl ?? this.photoUrl,
      inventoryCount: inventoryCount ?? this.inventoryCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    dosage,
    frequency,
    times,
    instructions,
    photoUrl,
    inventoryCount,
    createdAt,
  ];
}
