import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/medication_repository.dart';
import 'medications_event.dart';
import 'medications_state.dart';

class MedicationsBloc extends Bloc<MedicationsEvent, MedicationsState> {
  final MedicationRepository _medicationRepository;
  StreamSubscription? _medsSubscription;

  MedicationsBloc({required MedicationRepository medicationRepository})
    : _medicationRepository = medicationRepository,
      super(MedicationsInitial()) {
    on<LoadMedications>(_onLoadMedications);
    on<MedicationsUpdated>(_onMedicationsUpdated);
    on<AddMedicationRequested>(_onAddMedication);
    on<UpdateMedicationRequested>(_onUpdateMedication);
    on<DeleteMedicationRequested>(_onDeleteMedication);
  }

  Future<void> _onLoadMedications(
    LoadMedications event,
    Emitter<MedicationsState> emit,
  ) async {
    emit(MedicationsLoading());
    await _medsSubscription?.cancel();
    _medsSubscription = _medicationRepository
        .getMedicationsStream(event.userId)
        .listen((meds) => add(MedicationsUpdated(medications: meds)));
  }

  void _onMedicationsUpdated(
    MedicationsUpdated event,
    Emitter<MedicationsState> emit,
  ) {
    emit(MedicationsLoaded(medications: event.medications));
  }

  Future<void> _onAddMedication(
    AddMedicationRequested event,
    Emitter<MedicationsState> emit,
  ) async {
    try {
      await _medicationRepository.addMedication(event.medication);
    } catch (e) {
      emit(MedicationsError(message: e.toString()));
    }
  }

  Future<void> _onUpdateMedication(
    UpdateMedicationRequested event,
    Emitter<MedicationsState> emit,
  ) async {
    try {
      await _medicationRepository.updateMedication(event.medication);
    } catch (e) {
      emit(MedicationsError(message: e.toString()));
    }
  }

  Future<void> _onDeleteMedication(
    DeleteMedicationRequested event,
    Emitter<MedicationsState> emit,
  ) async {
    try {
      await _medicationRepository.deleteMedication(event.medicationId);
    } catch (e) {
      emit(MedicationsError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _medsSubscription?.cancel();
    return super.close();
  }
}