import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/validators.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/medications/medications_bloc.dart';
import '../../../logic/medications/medications_event.dart';
import '../../../data/models/medication_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddEditMedicationPage extends StatefulWidget {
  final MedicationModel? medication;

  const AddEditMedicationPage({super.key, this.medication});

  @override
  State<AddEditMedicationPage> createState() => _AddEditMedicationPageState();
}

class _AddEditMedicationPageState extends State<AddEditMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _instructionsController;
  late TextEditingController _inventoryController;

  String _selectedFrequency = 'Daily';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);

  final List<String> _frequencies = ['Daily', 'As Needed', 'Specific Days'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.medication?.name ?? '',
    );
    _dosageController = TextEditingController(
      text: widget.medication?.dosage ?? '',
    );
    _instructionsController = TextEditingController(
      text: widget.medication?.instructions ?? '',
    );
    _inventoryController = TextEditingController(
      text: (widget.medication?.inventoryCount ?? 30).toString(),
    );

    if (widget.medication != null) {
      _selectedFrequency = widget.medication!.frequency;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    _inventoryController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _onSavePressed() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;
      final uid = (authState is AuthAuthenticated)
          ? authState.user.uid
          : 'user_active';

      final timeFormatted =
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

      final med = MedicationModel(
        id: widget.medication?.id ?? '',
        userId: uid,
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: _selectedFrequency,
        times: [timeFormatted],
        instructions: _instructionsController.text.trim(),
        inventoryCount: int.tryParse(_inventoryController.text) ?? 30,
        createdAt: widget.medication?.createdAt ?? DateTime.now(),
      );

      // Schedule exact local notification reminder
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final notifService = NotificationService();
      notifService.scheduleNotification(
        id: med.name.hashCode,
        title: 'MedRemind Reminder: ${med.name}',
        body: 'Time to take ${med.dosage}. ${med.instructions}',
        scheduledTime: scheduledDate,
      );

      if (widget.medication == null) {
        context.read<MedicationsBloc>().add(
          AddMedicationRequested(medication: med),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder set for ${med.name} at $timeFormatted!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        context.read<MedicationsBloc>().add(
          UpdateMedicationRequested(medication: med),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder updated for ${med.name} at $timeFormatted!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.medication != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Medication' : 'Add Medication'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Medication Photo Upload Box
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 1.2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.add_a_photo_outlined,
                        size: 36,
                        color: AppColors.primary,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap to upload photo of bottle',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Medication Name *',
                  hint: 'e.g. Lisinopril, Metformin',
                  controller: _nameController,
                  validator: (val) =>
                      Validators.validateRequired(val, 'Medication Name'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Dosage *',
                  hint: 'e.g. 10mg, 1 tablet, 2 puffs',
                  controller: _dosageController,
                  validator: (val) =>
                      Validators.validateRequired(val, 'Dosage'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Frequency',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: _frequencies.map((freq) {
                    final isSelected = _selectedFrequency == freq;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFrequency = freq),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              freq,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Time',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickTime,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(
                          _selectedTime.format(context),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Inventory Count (Pills remaining)',
                  hint: 'e.g. 30',
                  controller: _inventoryController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Special Instructions (Optional)',
                  hint: 'e.g. Take with food, Drink plenty of water',
                  controller: _instructionsController,
                  maxLines: 3,
                ),
                const SizedBox(height: 28),
                CustomButton(
                  text: isEditing ? 'Update Medication' : 'Save Medication',
                  onPressed: _onSavePressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
