import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../logic/medications/medications_bloc.dart';
import '../../../logic/medications/medications_event.dart';
import '../../../data/models/medication_model.dart';
import '../../widgets/custom_button.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/dose_logs/dose_logs_bloc.dart';
import '../../../logic/dose_logs/dose_logs_event.dart';
import '../../../data/models/dose_log_model.dart';
import '../adherence/log_dose_modal.dart';

class MedicationDetailPage extends StatelessWidget {
  final MedicationModel medication;

  const MedicationDetailPage({super.key, required this.medication});

  void _onDeletePressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Medication'),
        content: Text('Are you sure you want to delete ${medication.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              context.read<MedicationsBloc>().add(
                DeleteMedicationRequested(medicationId: medication.id),
              );
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close detail page
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${medication.name} deleted.'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showLogDoseDialog(BuildContext context, MedicationModel med) {
    showDialog(
      context: context,
      builder: (_) => LogDoseModal(
        medication: med,
        onConfirm: () {
          final authState = context.read<AuthBloc>().state;
          final uid = (authState is AuthAuthenticated) ? authState.user.uid : 'user_active';
          
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
              content: Text('${med.name} dose logged!'),
              backgroundColor: AppColors.success,
            ),
          );
        },
        onSkip: () {
          final authState = context.read<AuthBloc>().state;
          final uid = (authState is AuthAuthenticated) ? authState.user.uid : 'user_active';
          
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
    final timesStr = medication.times.join(', ');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Medication Detail')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.medication_rounded,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${medication.dosage} • ${medication.frequency}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Schedule Card
              _DetailCard(
                icon: Icons.schedule,
                title: 'Schedule',
                content: medication.frequency,
                subtitle: timesStr.isNotEmpty ? timesStr : 'No set time',
              ),
              const SizedBox(height: 12),
              // Instructions Card
              _DetailCard(
                icon: Icons.restaurant,
                title: 'Instructions',
                content: medication.instructions.isNotEmpty
                    ? medication.instructions
                    : 'No special instructions provided.',
              ),
              const SizedBox(height: 12),
              // Inventory Card
              _DetailCard(
                icon: Icons.inventory_2_outlined,
                title: 'Inventory',
                content: '${medication.inventoryCount} Tablets remaining',
                subtitle: 'Refill recommended in 20 days',
              ),
              const Spacer(),
              CustomButton(
                text: 'Log Dose',
                icon: Icons.check_circle_outline,
                onPressed: () => _showLogDoseDialog(context, medication),
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Edit Medication',
                isSecondary: true,
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.editMedication,
                    arguments: medication,
                  );
                },
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Delete Medication',
                isSecondary: true,
                color: AppColors.error,
                onPressed: () => _onDeletePressed(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final String? subtitle;

  const _DetailCard({
    required this.icon,
    required this.title,
    required this.content,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
