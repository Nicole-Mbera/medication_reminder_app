import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/caregiver_repository.dart';
import 'caregivers_event.dart';
import 'caregivers_state.dart';

class CaregiversBloc extends Bloc<CaregiversEvent, CaregiversState> {
  final CaregiverRepository _caregiverRepository;
  StreamSubscription? _caregiversSubscription;

  CaregiversBloc({required CaregiverRepository caregiverRepository})
    : _caregiverRepository = caregiverRepository,
      super(CaregiversInitial()) {
    on<LoadCaregivers>(_onLoadCaregivers);
    on<CaregiversUpdated>(_onCaregiversUpdated);
    on<AddCaregiverRequested>(_onAddCaregiver);
    on<SendEmergencyAlertRequested>(_onSendEmergencyAlert);
  }

  Future<void> _onLoadCaregivers(
    LoadCaregivers event,
    Emitter<CaregiversState> emit,
  ) async {
    emit(CaregiversLoading());
    await _caregiversSubscription?.cancel();
    _caregiversSubscription = _caregiverRepository
        .getCaregiversStream(event.userId)
        .listen((cgs) => add(CaregiversUpdated(caregivers: cgs)));
  }

  void _onCaregiversUpdated(
    CaregiversUpdated event,
    Emitter<CaregiversState> emit,
  ) {
    emit(CaregiversLoaded(caregivers: event.caregivers));
  }

  Future<void> _onAddCaregiver(
    AddCaregiverRequested event,
    Emitter<CaregiversState> emit,
  ) async {
    try {
      await _caregiverRepository.addCaregiver(event.caregiver);
    } catch (e) {
      emit(CaregiversError(message: e.toString()));
    }
  }

  Future<void> _onSendEmergencyAlert(
    SendEmergencyAlertRequested event,
    Emitter<CaregiversState> emit,
  ) async {
    try {
      await _caregiverRepository.sendEmergencyAlert(event.userId);
      emit(EmergencyAlertSent());
    } catch (e) {
      emit(CaregiversError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _caregiversSubscription?.cancel();
    return super.close();
  }
}
