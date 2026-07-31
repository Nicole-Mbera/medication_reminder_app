import 'package:equatable/equatable.dart';
import '../../data/models/caregiver_model.dart';

abstract class CaregiversState extends Equatable {
  const CaregiversState();

  @override
  List<Object?> get props => [];
}

class CaregiversInitial extends CaregiversState {}

class CaregiversLoading extends CaregiversState {}

class CaregiversLoaded extends CaregiversState {
  final List<CaregiverModel> caregivers;

  const CaregiversLoaded({required this.caregivers});

  @override
  List<Object?> get props => [caregivers];
}

class CaregiversError extends CaregiversState {
  final String message;

  const CaregiversError({required this.message});

  @override
  List<Object?> get props => [message];
}

class EmergencyAlertSent extends CaregiversState {}
