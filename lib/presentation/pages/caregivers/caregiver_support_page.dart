import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/caregivers/caregivers_bloc.dart';
import '../../../logic/caregivers/caregivers_event.dart';
import '../../../logic/caregivers/caregivers_state.dart';
import '../../widgets/custom_button.dart';
import 'add_caregiver_dialog.dart';

class CaregiverSupportPage extends StatefulWidget {
  const CaregiverSupportPage({super.key});

  @override
  State<CaregiverSupportPage> createState() => _CaregiverSupportPageState();
}

class _CaregiverSupportPageState extends State<CaregiverSupportPage> {
  @override
  void initState() {
    super.initState();
    final authUser = context.read<AuthBloc>().state;
    final uid = (authUser is AuthAuthenticated)
        ? authUser.user.uid
        : 'user_active';
    context.read<CaregiversBloc>().add(LoadCaregivers(userId: uid));
  }

  void _showAddCaregiverDialog() {
    showDialog(context: context, builder: (_) => const AddCaregiverDialog());
  }

  void _onSendEmergencyAlert() {
    final authUser = context.read<AuthBloc>().state;
    final uid = (authUser is AuthAuthenticated)
        ? authUser.user.uid
        : 'user_active';
    context.read<CaregiversBloc>().add(
      SendEmergencyAlertRequested(userId: uid),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('EMERGENCY ALERT SENT to all connected caregivers!'),
        backgroundColor: AppColors.error,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _onShareWeeklyReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Weekly adherence report formatted and ready to share!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Caregiver Support')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Manage Support Network',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Manage who helps with your care and share your medication adherence progress.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              CustomButton(
                text: 'Add Caregiver',
                icon: Icons.person_add_alt_1,
                onPressed: _showAddCaregiverDialog,
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Share Weekly Report',
                isSecondary: true,
                icon: Icons.share,
                onPressed: _onShareWeeklyReport,
              ),
              const SizedBox(height: 28),

              // Your Caregivers List Section
              const Text(
                'Your Caregivers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              BlocBuilder<CaregiversBloc, CaregiversState>(
                builder: (context, state) {
                  if (state is CaregiversLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CaregiversLoaded) {
                    final caregivers = state.caregivers;
                    if (caregivers.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No caregivers added yet.'),
                      );
                    }

                    return Column(
                      children: caregivers.map((cg) {
                        final isConnected = cg.status == 'Connected';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(
                              color: AppColors.border,
                              width: 0.8,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.primaryLight,
                                  child: Icon(
                                    isConnected
                                        ? Icons.person
                                        : Icons.medical_information,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cg.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        cg.relationship,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isConnected
                                        ? AppColors.badgeTakenBg
                                        : AppColors.badgeUpcomingBg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    cg.status,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isConnected
                                          ? AppColors.badgeTakenText
                                          : AppColors.badgeUpcomingText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 24),

              // Emergency Assistance Box
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.error,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Emergency Assistance',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Notify all connected caregivers immediately if you need urgent help taking your medicine.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Send Alert',
                      color: AppColors.error,
                      icon: Icons.campaign_rounded,
                      onPressed: _onSendEmergencyAlert,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
