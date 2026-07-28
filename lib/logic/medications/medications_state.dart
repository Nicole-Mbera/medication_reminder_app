import 'package:equatable/equatable.dart';
import '../../data/models/medication_model.dart';

abstract class MedicationsState extends Equatable {
  const MedicationsState();

  @override
  List<Object?> get props => [];
}

class MedicationsInitial extends MedicationsState {}

class MedicationsLoading extends MedicationsState {}

class MedicationsLoaded extends MedicationsState {
  final List<MedicationModel> medications;

  const MedicationsLoaded({required this.medications});

  @override
  List<Object?> get props => [medications];
}

class MedicationsError extends MedicationsState {
  final String message;

  const MedicationsError({required this.message});

  @override
  List<Object?> get props => [message];
}