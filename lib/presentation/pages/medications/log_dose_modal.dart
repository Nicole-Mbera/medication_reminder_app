import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/medication_model.dart';
import '../../widgets/custom_button.dart';

class LogDoseModal extends StatelessWidget {
  final MedicationModel medication;
  final VoidCallback onConfirm;
  final VoidCallback onSkip;

  const LogDoseModal({
    super.key,
    required this.medication,
    required this.onConfirm,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medication_rounded,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.badgeUpcomingBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'SCHEDULED FOR ${medication.times.isNotEmpty ? medication.times.first : "8:00 AM"}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.badgeUpcomingText,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Did you take ${medication.name}?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${medication.dosage} • ${medication.instructions}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Yes, I took it',
              icon: Icons.check,
              onPressed: () {
                onConfirm();
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Skip this dose',
              isSecondary: true,
              color: AppColors.textSecondary,
              onPressed: () {
                onSkip();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
