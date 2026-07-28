import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String language;
  final String healthCondition; // e.g. 'Diabetes', 'Hypertension', 'HIV/AIDS', 'Asthma', 'General Wellness'
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.language = 'English',
    this.healthCondition = 'Diabetes',
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      uid: docId,
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      language: map['language'] ?? 'English',
      healthCondition: map['healthCondition'] ?? 'Diabetes',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'language': language,
      'healthCondition': healthCondition,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        fullName,
        phoneNumber,
        language,
        healthCondition,
        createdAt,
      ];
}
