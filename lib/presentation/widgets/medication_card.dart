import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/medication_model.dart';

class MedicationCard extends StatelessWidget {
  final MedicationModel medication;
  final String status; // 'Taken', 'Missed', 'Upcoming', 'As Needed'
  final String timeDisplay;
  final VoidCallback? onTap;
  final VoidCallback? onLogDose;

  const MedicationCard({
    super.key,
    required this.medication,
    this.status = 'Upcoming',
    required this.timeDisplay,
    this.onTap,
    this.onLogDose,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeBg;
    Color badgeText;
    IconData iconData = Icons.medication;

    switch (status) {
      case 'Taken':
        badgeBg = AppColors.badgeTakenBg;
        badgeText = AppColors.badgeTakenText;
        break;
      case 'Missed':
        badgeBg = AppColors.badgeMissedBg;
        badgeText = AppColors.badgeMissedText;
        break;
      case 'As Needed':
        badgeBg = AppColors.primaryLight;
        badgeText = AppColors.primaryDark;
        break;
      case 'Upcoming':
      default:
        badgeBg = AppColors.badgeUpcomingBg;
        badgeText = AppColors.badgeUpcomingText;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 0.8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          medication.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: badgeText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${medication.dosage} • ${medication.frequency}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeDisplay,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
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