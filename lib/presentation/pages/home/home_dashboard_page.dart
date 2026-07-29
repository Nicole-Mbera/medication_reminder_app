import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_localizations.dart';
import '../../../core/router/app_router.dart';
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
import '../../widgets/progress_ring.dart';
import '../adherence/log_dose_modal.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final uid = (authState is AuthAuthenticated) ? authState.user.uid : 'user_active';
    context.read<MedicationsBloc>().add(LoadMedications(userId: uid));
    context.read<DoseLogsBloc>().add(LoadDoseLogs(userId: uid));
  }

  String _getCurrentUserId() {
    final authState = context.read<AuthBloc>().state;
    return (authState is AuthAuthenticated) ? authState.user.uid : 'user_active';
  }

  void _showLogDoseDialog(BuildContext context, MedicationModel med) {
    showDialog(
      context: context,
      builder: (_) => LogDoseModal(
        medication: med,
        onConfirm: () {
          final uid = _getCurrentUserId();
          context.read<DoseLogsBloc>().add(
                LogDoseRequested(
                  log: DoseLogModel(
                    id: '',
                    medicationId: med.id,
                    medicationName: med.name,
                    userId: uid,
                    scheduledTime: DateTime.now(),
                    status: 'taken',
                    loggedAt: DateTime.now(),
                  ),
                ),
              );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${med.name} dose logged as taken!'),
              backgroundColor: AppColors.success,
            ),
          );
        },
        onSkip: () {
          final uid = _getCurrentUserId();
          context.read<DoseLogsBloc>().add(
                LogDoseRequested(
                  log: DoseLogModel(
                    id: '',
                    medicationId: med.id,
                    medicationName: med.name,
                    userId: uid,
                    scheduledTime: DateTime.now(),
                    status: 'missed',
                    loggedAt: DateTime.now(),
                  ),
                ),
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final loc = AppLocalizations.of(settings.language);

    final authState = context.watch<AuthBloc>().state;
    final userName = (authState is AuthAuthenticated)
        ? authState.user.fullName
        : 'Patient';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.person, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MedRemind',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '${loc.translate('good_morning')}, $userName.',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                loc.translate('care_plan_subtitle'),
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // Dynamic Due Now Card
              BlocBuilder<MedicationsBloc, MedicationsState>(
                builder: (context, medState) {
                  final List<MedicationModel> meds =
                      (medState is MedicationsLoaded)
                          ? medState.medications
                          : [];

                  if (meds.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border, width: 0.8),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.medication_outlined,
                            size: 44,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'No medications scheduled yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tap "+ Add Med" below to create your first prescription schedule.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: Text(
                              loc.translate('add_med'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, AppRoutes.addMedication);
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  final dueMed = meds.first;

                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppColors.primaryLight, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time_filled,
                                    size: 16, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  '${loc.translate('due_now')} • ${dueMed.times.isNotEmpty ? dueMed.times.first : "08:00 AM"}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.medical_services_outlined,
                                color: AppColors.primary),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          dueMed.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${dueMed.dosage}${dueMed.instructions.isNotEmpty ? " • ${dueMed.instructions}" : ""}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon:
                                const Icon(Icons.check_circle_outline, size: 20),
                            label: Text(
                              loc.translate('log_dose'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () =>
                                _showLogDoseDialog(context, dueMed),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Daily Progress Ring Card
              BlocBuilder<DoseLogsBloc, DoseLogsState>(
                builder: (context, logState) {
                  final pct = (logState is DoseLogsLoaded)
                      ? logState.adherencePercentage
                      : 100.0;

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border, width: 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.translate('daily_progress'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: ProgressRing(percentage: pct),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            loc.translate('great_job'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Quick Action Cards
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.addMedication);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border, width: 0.8),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.add_circle_outline,
                                color: AppColors.primary, size: 28),
                            const SizedBox(height: 8),
                            Text(
                              loc.translate('add_med'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.caregivers);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border, width: 0.8),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.contact_support_outlined,
                                color: AppColors.primary, size: 28),
                            const SizedBox(height: 8),
                            Text(
                              loc.translate('contact_support'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Dynamic Coming Up Next Section
              Text(
                loc.translate('coming_up_next'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              BlocBuilder<MedicationsBloc, MedicationsState>(
                builder: (context, medState) {
                  final List<MedicationModel> meds =
                      (medState is MedicationsLoaded)
                          ? medState.medications
                          : [];

                  if (meds.length < 2) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 0.8),
                      ),
                      child: const Text(
                        'No additional upcoming medications for today.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }

                  final nextMed = meds[1];

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 0.8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.medication,
                              color: AppColors.primary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nextMed.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${nextMed.dosage} • ${nextMed.times.isNotEmpty ? nextMed.times.first : "Scheduled"}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
