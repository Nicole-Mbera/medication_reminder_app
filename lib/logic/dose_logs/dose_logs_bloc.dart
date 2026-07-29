import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/dose_log_repository.dart';
import 'dose_logs_event.dart';
import 'dose_logs_state.dart';

class DoseLogsBloc extends Bloc<DoseLogsEvent, DoseLogsState> {
  final DoseLogRepository _doseLogRepository;
  StreamSubscription? _logsSubscription;

  DoseLogsBloc({required DoseLogRepository doseLogRepository})
    : _doseLogRepository = doseLogRepository,
      super(DoseLogsInitial()) {
    on<LoadDoseLogs>(_onLoadDoseLogs);
    on<DoseLogsUpdated>(_onDoseLogsUpdated);
    on<LogDoseRequested>(_onLogDoseRequested);
  }

  Future<void> _onLoadDoseLogs(
    LoadDoseLogs event,
    Emitter<DoseLogsState> emit,
  ) async {
    emit(DoseLogsLoading());
    await _logsSubscription?.cancel();
    _logsSubscription = _doseLogRepository
        .getDoseLogsStream(event.userId)
        .listen((logs) => add(DoseLogsUpdated(logs: logs)));
  }

  void _onDoseLogsUpdated(DoseLogsUpdated event, Emitter<DoseLogsState> emit) {
    final adherencePct = _doseLogRepository.calculateAdherencePercentage(
      event.logs,
    );
    emit(DoseLogsLoaded(logs: event.logs, adherencePercentage: adherencePct));
  }

  Future<void> _onLogDoseRequested(
    LogDoseRequested event,
    Emitter<DoseLogsState> emit,
  ) async {
    try {
      await _doseLogRepository.logDose(event.log);
    } catch (e) {
      emit(DoseLogsError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _logsSubscription?.cancel();
    return super.close();
  }
}
