import 'package:equatable/equatable.dart';
import '../../data/models/caregiver_model.dart';

abstract class CaregiversEvent extends Equatable {
  const CaregiversEvent();

  @override
  List<Object?> get props => [];
}

class LoadCaregivers extends CaregiversEvent {
  final String userId;

  const LoadCaregivers({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AddCaregiverRequested extends CaregiversEvent {
  final CaregiverModel caregiver;

  const AddCaregiverRequested({required this.caregiver});

  @override
  List<Object?> get props => [caregiver];
}

class CaregiversUpdated extends CaregiversEvent {
  final List<CaregiverModel> caregivers;

  const CaregiversUpdated({required this.caregivers});

  @override
  List<Object?> get props => [caregivers];
}

class SendEmergencyAlertRequested extends CaregiversEvent {
  final String userId;

  const SendEmergencyAlertRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}
