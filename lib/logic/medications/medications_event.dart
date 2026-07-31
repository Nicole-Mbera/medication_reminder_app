import 'package:equatable/equatable.dart';
import '../../data/models/medication_model.dart';

abstract class MedicationsEvent extends Equatable {
  const MedicationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMedications extends MedicationsEvent {
  final String userId;

  const LoadMedications({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AddMedicationRequested extends MedicationsEvent {
  final MedicationModel medication;

  const AddMedicationRequested({required this.medication});

  @override
  List<Object?> get props => [medication];
}

class UpdateMedicationRequested extends MedicationsEvent {
  final MedicationModel medication;

  const UpdateMedicationRequested({required this.medication});

  @override
  List<Object?> get props => [medication];
}

class DeleteMedicationRequested extends MedicationsEvent {
  final String medicationId;

  const DeleteMedicationRequested({required this.medicationId});

  @override
  List<Object?> get props => [medicationId];
}

class MedicationsUpdated extends MedicationsEvent {
  final List<MedicationModel> medications;

  const MedicationsUpdated({required this.medications});

  @override
  List<Object?> get props => [medications];
}
