import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/caregivers/caregivers_bloc.dart';
import '../../../logic/caregivers/caregivers_event.dart';
import '../../../data/models/caregiver_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddCaregiverDialog extends StatefulWidget {
  const AddCaregiverDialog({super.key});

  @override
  State<AddCaregiverDialog> createState() => _AddCaregiverDialogState();
}

class _AddCaregiverDialogState extends State<AddCaregiverDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _relationshipController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  void _onAddPressed() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;
      final uid = (authState is AuthAuthenticated)
          ? authState.user.uid
          : 'user_active';

      final cg = CaregiverModel(
        id: '',
        userId: uid,
        name: _nameController.text.trim(),
        relationship: _relationshipController.text.trim(),
        email: _emailController.text.trim(),
        status: 'Pending Invite',
        createdAt: DateTime.now(),
      );

      context.read<CaregiversBloc>().add(AddCaregiverRequested(caregiver: cg));
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invitation sent to ${cg.name}!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Caregiver',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Full Name *',
                hint: 'e.g. Jane Doe',
                controller: _nameController,
                validator: (val) =>
                    Validators.validateRequired(val, 'Caregiver Name'),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Relationship *',
                hint: 'e.g. Daughter, Primary Physician',
                controller: _relationshipController,
                validator: (val) =>
                    Validators.validateRequired(val, 'Relationship'),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Email Address *',
                hint: 'e.g. jane.doe@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 24),
              CustomButton(text: 'Send Invite', onPressed: _onAddPressed),
            ],
          ),
        ),
      ),
    );
  }
}
