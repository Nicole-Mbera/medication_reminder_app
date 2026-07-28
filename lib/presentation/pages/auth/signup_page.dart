import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/validators.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_event.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/settings/settings_cubit.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedLanguage = 'English';
  String _selectedHealthCondition = 'Diabetes';

  final List<String> _languages = [
    'English',
    'Kinyarwanda',
    'French',
    'Swahili'
  ];

  final List<String> _healthConditions = [
    'Diabetes',
    'Hypertension',
    'HIV/AIDS',
    'Asthma',
    'Heart Disease',
    'General Wellness',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignUpPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<SettingsCubit>().changeLanguage(_selectedLanguage);
      context.read<AuthBloc>().add(
            SignUpRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              fullName: _nameController.text.trim(),
              phoneNumber: _phoneController.text.trim(),
              healthCondition: _selectedHealthCondition,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final loc = AppLocalizations.of(settings.language);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else if (state is AuthEmailNotVerified) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.verifyEmail,
              arguments: state.email,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: const [
                          Icon(
                            Icons.medical_services_rounded,
                            size: 48,
                            color: AppColors.primary,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'MedRemind',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      loc.translate('create_account'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Please fill in your details to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Language Dropdown
                    Text(
                      loc.translate('language'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedLanguage,
                      decoration: const InputDecoration(
                        prefixIcon:
                            Icon(Icons.language, color: AppColors.primary),
                      ),
                      items: _languages.map((lang) {
                        return DropdownMenuItem(
                          value: lang,
                          child: Text(lang),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedLanguage = val);
                          context.read<SettingsCubit>().changeLanguage(val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Full Name',
                      hint: 'e.g. Mary Smith',
                      controller: _nameController,
                      validator: Validators.validateName,
                      prefixIcon: const Icon(Icons.person_outline,
                          color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Email Address',
                      hint: 'e.g. mary.smith@email.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Phone Number',
                      hint: 'e.g. +250 788 123 456',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (val) =>
                          Validators.validateRequired(val, 'Phone Number'),
                      prefixIcon: const Icon(Icons.phone_outlined,
                          color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),

                    // Health Condition Selector
                    const Text(
                      'Primary Health Condition *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedHealthCondition,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.health_and_safety_outlined,
                            color: AppColors.primary),
                      ),
                      items: _healthConditions.map((condition) {
                        return DropdownMenuItem(
                          value: condition,
                          child: Text(condition),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedHealthCondition = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Password',
                      hint: 'At least 6 characters',
                      controller: _passwordController,
                      obscureText: true,
                      validator: Validators.validatePassword,
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      controller: _confirmPasswordController,
                      obscureText: true,
                      validator: (val) => Validators.validateConfirmPassword(
                          val, _passwordController.text),
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: AppColors.primary),
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: loc.translate('create_account'),
                      isLoading: isLoading,
                      onPressed: _onSignUpPressed,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                                context, AppRoutes.login);
                          },
                          child: Text(
                            loc.translate('sign_in'),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
