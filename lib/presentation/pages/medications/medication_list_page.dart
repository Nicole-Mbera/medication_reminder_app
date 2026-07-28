import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/dose_logs/dose_logs_bloc.dart';
import '../../../logic/dose_logs/dose_logs_state.dart';
import '../../../logic/medications/medications_bloc.dart';
import '../../../logic/medications/medications_event.dart';
import '../../../logic/medications/medications_state.dart';
import '../../../logic/settings/settings_cubit.dart';
import '../../widgets/medication_card.dart';

class MedicationListPage extends StatefulWidget {
  const MedicationListPage({super.key});

  @override
  State<MedicationListPage> createState() => _MedicationListPageState();
}

class _MedicationListPageState extends State<MedicationListPage> {
  @override
  void initState() {
    super.initState();
    final authUser = context.read<AuthBloc>().state;
    final uid =
        (authUser is AuthAuthenticated) ? authUser.user.uid : 'user_active';
    context.read<MedicationsBloc>().add(LoadMedications(userId: uid));
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final loc = AppLocalizations.of(settings.language);
    final dateStr = DateFormat('EEEE, MMM d').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.translate('medications')),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addMedication);
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.translate('todays_schedule'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BlocBuilder<MedicationsBloc, MedicationsState>(
                  builder: (context, medState) {
                    return BlocBuilder<DoseLogsBloc, DoseLogsState>(
                      builder: (context, logState) {
                        if (medState is MedicationsLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (medState is MedicationsLoaded) {
                          final meds = medState.medications;
                          final logs = (logState is DoseLogsLoaded)
                              ? logState.logs
                              : [];

                          if (meds.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.medication_outlined,
                                      size: 64, color: AppColors.textLight),
                                  SizedBox(height: 12),
                                  Text(
                                    'No medications added yet.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final now = DateTime.now();

                          return ListView.builder(
                            itemCount: meds.length,
                            itemBuilder: (context, index) {
                              final med = meds[index];

                              // Find today's log for this medication
                              final todayLog = logs.where((l) =>
                                  l.medicationName.toLowerCase() ==
                                      med.name.toLowerCase() &&
                                  l.scheduledTime.year == now.year &&
                                  l.scheduledTime.month == now.month &&
                                  l.scheduledTime.day == now.day);

                              String status = 'Upcoming';
                              if (todayLog.isNotEmpty) {
                                final logStatus = todayLog.first.status;
                                if (logStatus == 'taken') {
                                  status = 'Taken';
                                } else if (logStatus == 'missed') {
                                  status = 'Missed';
                                }
                              } else if (med.frequency == 'As Needed') {
                                status = 'As Needed';
                              }

                              final timeDisplay = med.times.isNotEmpty
                                  ? med.times.first
                                  : 'As needed';

                              return MedicationCard(
                                medication: med,
                                status: status,
                                timeDisplay: timeDisplay,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.medicationDetail,
                                    arguments: med,
                                  );
                                },
                              );
                            },
                          );
                        } else if (medState is MedicationsError) {
                          return Center(child: Text(medState.message));
                        }
                        return const SizedBox.shrink();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}