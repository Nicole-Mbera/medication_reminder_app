import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_localizations.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/dose_logs/dose_logs_bloc.dart';
import '../../../logic/dose_logs/dose_logs_event.dart';
import '../../../logic/dose_logs/dose_logs_state.dart';
import '../../../logic/medications/medications_bloc.dart';
import '../../../logic/medications/medications_event.dart';
import '../../../logic/medications/medications_state.dart';
import '../../../logic/settings/settings_cubit.dart';
import '../../../data/models/medication_model.dart';
import '../../../data/models/dose_log_model.dart';
import '../../widgets/adherence_heatmap.dart';

class AdherenceTrackerPage extends StatefulWidget {
  const AdherenceTrackerPage({super.key});

  @override
  State<AdherenceTrackerPage> createState() => _AdherenceTrackerPageState();
}

class _AdherenceTrackerPageState extends State<AdherenceTrackerPage> {
  @override
  void initState() {
    super.initState();
    final authUser = context.read<AuthBloc>().state;
    final uid =
        (authUser is AuthAuthenticated) ? authUser.user.uid : 'user_active';
    context.read<MedicationsBloc>().add(LoadMedications(userId: uid));
    context.read<DoseLogsBloc>().add(LoadDoseLogs(userId: uid));
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final loc = AppLocalizations.of(settings.language);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.translate('progress')),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.translate('weekly_progress'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Track your consistency across all prescribed medications.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Weekly Progress Banner Card
              BlocBuilder<DoseLogsBloc, DoseLogsState>(
                builder: (context, state) {
                  final logs = (state is DoseLogsLoaded) ? state.logs : [];
                  final takenCount =
                      logs.where((l) => l.status == 'taken').length;
                  final totalCount = logs.length;
                  final pct = totalCount == 0
                      ? 100.0
                      : ((takenCount / totalCount) * 100.0);

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              loc.translate('great_job'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "You've taken $takenCount of $totalCount doses logged!",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${pct.toInt()}% ${loc.translate('adherence_rate')}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Adherence Heatmap Grid
              BlocBuilder<MedicationsBloc, MedicationsState>(
                builder: (context, medState) {
                  return BlocBuilder<DoseLogsBloc, DoseLogsState>(
                    builder: (context, logState) {
                      final List<MedicationModel> meds =
                          (medState is MedicationsLoaded)
                              ? medState.medications
                              : [];
                      final List<DoseLogModel> logs =
                          (logState is DoseLogsLoaded) ? logState.logs : [];

                      return AdherenceHeatmap(
                        medications: meds,
                        logs: logs,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
