import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_event.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/settings/settings_cubit.dart';
import '../../widgets/custom_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _onLogoutPressed(BuildContext context, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.translate('log_out')),
        content: const Text('Are you sure you want to log out of MedRemind?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
            child: Text(loc.translate('log_out')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userName = (authState is AuthAuthenticated)
        ? authState.user.fullName
        : 'Active Patient';
    final userEmail = (authState is AuthAuthenticated)
        ? authState.user.email
        : 'patient@medremind.com';

    final settings = context.watch<SettingsCubit>().state;
    final loc = AppLocalizations.of(settings.language);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.translate('settings')),
      ),
      body: SafeArea(
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
            final cubit = context.read<SettingsCubit>();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 0.8),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.primaryLight,
                          child: Icon(Icons.person,
                              color: AppColors.primary, size: 30),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                userEmail,
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
                  ),
                  const SizedBox(height: 24),

                  // App Preferences Section
                  Text(
                    loc.translate('app_preferences'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Language Preference
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 0.8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.language,
                                color: AppColors.primary),
                            const SizedBox(width: 12),
                            Text(
                              loc.translate('language'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        DropdownButton<String>(
                          value: settingsState.language,
                          underline: const SizedBox.shrink(),
                          items: ['English', 'Kinyarwanda', 'French', 'Swahili']
                              .map((lang) => DropdownMenuItem(
                                    value: lang,
                                    child: Text(lang),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) cubit.changeLanguage(val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Notification Sounds Switch
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 0.8),
                    ),
                    child: SwitchListTile(
                      activeThumbColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      secondary: const Icon(
                        Icons.volume_up,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        loc.translate('notification_sounds'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: const Text(
                        'Chimes for pill reminders',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: settingsState.notificationSounds,
                      onChanged: (val) => cubit.toggleNotificationSounds(val),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Font Size Options
                  Container(
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
                            const Icon(Icons.text_fields,
                                color: AppColors.primary),
                            const SizedBox(width: 12),
                            Text(
                              loc.translate('font_size'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: ['Normal', 'Large'].map((size) {
                            final isSelected = settingsState.fontSize == size;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => cubit.changeFontSize(size),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.background,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.border,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      size,
                                      style: TextStyle(
                                        fontSize: 14,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Caregiver Support Link
                  InkWell(
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
                      child: Row(
                        children: [
                          const Icon(Icons.family_restroom,
                              color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              loc.translate('caregiver_support'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: AppColors.textLight),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Health Education Library Link
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.education);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 0.8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.school, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              loc.translate('library_resources'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: AppColors.textLight),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Offline Mode Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 0.8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.wifi_off, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.translate('offline_mode'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Local persistence enabled',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Logout Button
                  CustomButton(
                    text: loc.translate('log_out'),
                    isSecondary: true,
                    color: AppColors.error,
                    icon: Icons.logout,
                    onPressed: () => _onLogoutPressed(context, loc),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
