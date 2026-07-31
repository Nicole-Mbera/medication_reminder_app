import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:medremind/core/services/shared_prefs_service.dart';
import 'package:medremind/logic/auth/auth_bloc.dart';
import 'package:medremind/logic/auth/auth_state.dart';
import 'package:medremind/logic/medications/medications_bloc.dart';
import 'package:medremind/logic/medications/medications_state.dart';
import 'package:medremind/logic/dose_logs/dose_logs_bloc.dart';
import 'package:medremind/logic/dose_logs/dose_logs_state.dart';
import 'package:medremind/logic/caregivers/caregivers_bloc.dart';
import 'package:medremind/logic/caregivers/caregivers_state.dart';
import 'package:medremind/logic/education/education_cubit.dart';
import 'package:medremind/logic/settings/settings_cubit.dart';
import 'package:medremind/presentation/pages/shell/main_navigation_shell.dart';
import 'package:medremind/data/models/user_model.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class MockMedicationsBloc extends Mock implements MedicationsBloc {}

class MockDoseLogsBloc extends Mock implements DoseLogsBloc {}

class MockCaregiversBloc extends Mock implements CaregiversBloc {}

class MockEducationCubit extends Mock implements EducationCubit {}

class MockSharedPrefsService extends Mock implements SharedPrefsService {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockMedicationsBloc mockMedicationsBloc;
  late MockDoseLogsBloc mockDoseLogsBloc;
  late MockCaregiversBloc mockCaregiversBloc;
  late MockEducationCubit mockEducationCubit;
  late MockSharedPrefsService mockSharedPrefsService;
  late SettingsCubit settingsCubit;

  final testUser = UserModel(
    uid: 'u1',
    email: 'test@medremind.com',
    fullName: 'Margaret Johnson',
    phoneNumber: '555-0192',
    createdAt: DateTime.now(),
  );

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockMedicationsBloc = MockMedicationsBloc();
    mockDoseLogsBloc = MockDoseLogsBloc();
    mockCaregiversBloc = MockCaregiversBloc();
    mockEducationCubit = MockEducationCubit();
    mockSharedPrefsService = MockSharedPrefsService();

    when(() => mockSharedPrefsService.language).thenReturn('English');
    when(() => mockSharedPrefsService.fontSize).thenReturn('Normal');
    when(() => mockSharedPrefsService.notificationSounds).thenReturn(true);
    when(() => mockSharedPrefsService.offlineMode).thenReturn(false);

    settingsCubit = SettingsCubit(mockSharedPrefsService);

    when(() => mockAuthBloc.state)
        .thenReturn(AuthAuthenticated(user: testUser));
    when(() => mockAuthBloc.stream)
        .thenAnswer((_) => Stream.value(AuthAuthenticated(user: testUser)));

    when(() => mockMedicationsBloc.state)
        .thenReturn(const MedicationsLoaded(medications: []));
    when(() => mockMedicationsBloc.stream).thenAnswer(
        (_) => Stream.value(const MedicationsLoaded(medications: [])));

    when(() => mockDoseLogsBloc.state).thenReturn(
        const DoseLogsLoaded(logs: [], adherencePercentage: 100.0));
    when(() => mockDoseLogsBloc.stream).thenAnswer((_) => Stream.value(
        const DoseLogsLoaded(logs: [], adherencePercentage: 100.0)));

    when(() => mockCaregiversBloc.state)
        .thenReturn(const CaregiversLoaded(caregivers: []));
    when(() => mockCaregiversBloc.stream)
        .thenAnswer((_) => Stream.value(const CaregiversLoaded(caregivers: [])));

    when(() => mockEducationCubit.state)
        .thenReturn(const EducationLoaded(articles: []));
    when(() => mockEducationCubit.stream)
        .thenAnswer((_) => Stream.value(const EducationLoaded(articles: [])));
    when(() => mockEducationCubit.loadArticles()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        BlocProvider<MedicationsBloc>.value(value: mockMedicationsBloc),
        BlocProvider<DoseLogsBloc>.value(value: mockDoseLogsBloc),
        BlocProvider<CaregiversBloc>.value(value: mockCaregiversBloc),
        BlocProvider<EducationCubit>.value(value: mockEducationCubit),
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
      ],
      child: const MaterialApp(
        home: MainNavigationShell(),
      ),
    );
  }

  testWidgets(
      'MainNavigationShell renders bottom navigation bar and switches tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Verify Home tab initially active
    expect(find.textContaining('Margaret'), findsOneWidget);
    expect(find.text('Daily Progress'), findsOneWidget);

    // Tap Meds tab in bottom bar
    await tester.tap(find.byIcon(Icons.medication_outlined).last);
    await tester.pumpAndSettle();

    expect(find.text("Today's Schedule"), findsOneWidget);

    // Tap Settings tab
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('App Preferences'), findsOneWidget);
  });
}
