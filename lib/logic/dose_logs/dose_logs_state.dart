import 'package:equatable/equatable.dart';
import '../../data/models/dose_log_model.dart';

abstract class DoseLogsState extends Equatable {
  const DoseLogsState();

  @override
  List<Object?> get props => [];
}

class DoseLogsInitial extends DoseLogsState {}

class DoseLogsLoading extends DoseLogsState {}

class DoseLogsLoaded extends DoseLogsState {
  final List<DoseLogModel> logs;
  final double adherencePercentage;

  const DoseLogsLoaded({required this.logs, required this.adherencePercentage});

  @override
  List<Object?> get props => [logs, adherencePercentage];
}

class DoseLogsError extends DoseLogsState {
  final String message;

  const DoseLogsError({required this.message});

  @override
  List<Object?> get props => [message];
}
