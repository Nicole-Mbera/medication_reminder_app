import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'core/constants/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/shared_prefs_service.dart';

// Repositories
import 'data/repositories/auth_repository.dart';
import 'data/repositories/caregiver_repository.dart';
import 'data/repositories/dose_log_repository.dart';
import 'data/repositories/education_repository.dart';
import 'data/repositories/medication_repository.dart';

// BLoCs and Cubits
import 'logic/auth/auth_bloc.dart';
import 'logic/auth/auth_event.dart';
import 'logic/caregivers/caregivers_bloc.dart';
import 'logic/dose_logs/dose_logs_bloc.dart';
import 'logic/education/education_cubit.dart';
import 'logic/medications/medications_bloc.dart';
import 'logic/settings/settings_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kIsWeb) {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: false,
      );
    }
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  final sharedPrefsService = await SharedPrefsService.init();
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    MedRemindApp(
      sharedPrefsService: sharedPrefsService,
      notificationService: notificationService,
    ),
  );
}

class MedRemindApp extends StatelessWidget {
  final SharedPrefsService sharedPrefsService;
  final NotificationService notificationService;

  const MedRemindApp({
    super.key,
    required this.sharedPrefsService,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => AuthRepository()),
        RepositoryProvider<MedicationRepository>(
          create: (_) => MedicationRepository(),
        ),
        RepositoryProvider<DoseLogRepository>(
          create: (_) => DoseLogRepository(),
        ),
        RepositoryProvider<CaregiverRepository>(
          create: (_) => CaregiverRepository(),
        ),
        RepositoryProvider<EducationRepository>(
          create: (_) => EducationRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>())
                  ..add(AppStarted()),
          ),
          BlocProvider<MedicationsBloc>(
            create: (context) => MedicationsBloc(
              medicationRepository: context.read<MedicationRepository>(),
            ),
          ),
          BlocProvider<DoseLogsBloc>(
            create: (context) => DoseLogsBloc(
              doseLogRepository: context.read<DoseLogRepository>(),
            ),
          ),
          BlocProvider<CaregiversBloc>(
            create: (context) => CaregiversBloc(
              caregiverRepository: context.read<CaregiverRepository>(),
            ),
          ),
          BlocProvider<EducationCubit>(
            create: (context) => EducationCubit(
              educationRepository: context.read<EducationRepository>(),
            ),
          ),
          BlocProvider<SettingsCubit>(
            create: (_) => SettingsCubit(sharedPrefsService),
          ),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(settingsState.fontScale),
              ),
              child: MaterialApp(
                title: 'MedRemind',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                initialRoute: AppRoutes.splash,
                onGenerateRoute: AppRoutes.generateRoute,
              ),
            );
          },
        ),
      ),
    );
  }
}
