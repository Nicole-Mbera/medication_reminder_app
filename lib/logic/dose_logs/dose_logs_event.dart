import 'package:equatable/equatable.dart';
import '../../data/models/dose_log_model.dart';

abstract class DoseLogsEvent extends Equatable {
  const DoseLogsEvent();

  @override
  List<Object?> get props => [];
}

class LoadDoseLogs extends DoseLogsEvent {
  final String userId;

  const LoadDoseLogs({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class LogDoseRequested extends DoseLogsEvent {
  final DoseLogModel log;

  const LogDoseRequested({required this.log});

  @override
  List<Object?> get props => [log];
}

class DoseLogsUpdated extends DoseLogsEvent {
  final List<DoseLogModel> logs;

  const DoseLogsUpdated({required this.logs});

  @override
  List<Object?> get props => [logs];
}
