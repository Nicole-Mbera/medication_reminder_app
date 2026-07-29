import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/dose_log_model.dart';
import '../../data/models/medication_model.dart';

class AdherenceHeatmap extends StatelessWidget {
  final List<MedicationModel> medications;
  final List<DoseLogModel> logs;

  const AdherenceHeatmap({
    super.key,
    required this.medications,
    required this.logs,
  });

  @override
  Widget build(BuildContext context) {
    final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Medication Heatmap',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: const [
                  _LegendDot(color: AppColors.success, label: 'Taken'),
                  SizedBox(width: 12),
                  _LegendDot(color: AppColors.error, label: 'Missed'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Day Header
          Row(
            children: [
              const SizedBox(width: 90), // Offset for medication name
              ...daysOfWeek.map(
                (day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row per medication
          if (medications.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('No medications scheduled for heatmap.'),
              ),
            )
          else
            ...medications.map((med) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        med.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ...List.generate(7, (index) {
                      final status = _getStatusForDay(med.name, index);
                      return Expanded(
                        child: Center(
                          child: _StatusCircle(status: status),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  String _getStatusForDay(String medName, int dayIndex) {
    // 0 = Mon, 6 = Sun
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final targetDate = firstDayOfWeek.add(Duration(days: dayIndex));

    final match = logs.where((l) =>
        l.medicationName.toLowerCase() == medName.toLowerCase() &&
        l.scheduledTime.year == targetDate.year &&
        l.scheduledTime.month == targetDate.month &&
        l.scheduledTime.day == targetDate.day);

    if (match.isNotEmpty) {
      return match.first.status;
    }
    return 'none';
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _StatusCircle extends StatelessWidget {
  final String status; // 'taken', 'missed', 'none'

  const _StatusCircle({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == 'taken') {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 16, color: Colors.white),
      );
    } else if (status == 'missed') {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.error,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close, size: 16, color: Colors.white),
      );
    }
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
    );
  }
}
