import 'package:flutter/material.dart';
import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/onboarding/onboarding_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/signup_page.dart';
import '../../presentation/pages/auth/verify_email_page.dart';
import '../../presentation/pages/auth/forgot_password_page.dart';
import '../../presentation/pages/shell/main_navigation_shell.dart';
import '../../presentation/pages/medications/add_edit_medication_page.dart';
import '../../presentation/pages/medications/medication_detail_page.dart';
import '../../presentation/pages/education/article_detail_page.dart';
import '../../presentation/pages/caregivers/caregiver_support_page.dart';
import '../../data/models/medication_model.dart';
import '../../data/models/education_content_model.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String verifyEmail = '/verify-email';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String medications = '/medications';
  static const String addMedication = '/add-medication';
  static const String editMedication = '/edit-medication';
  static const String medicationDetail = '/medication-detail';
  static const String adherence = '/adherence';
  static const String caregivers = '/caregivers';
  static const String education = '/education';
  static const String articleDetail = '/article-detail';
  static const String settingsPage = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignUpPage());
      case verifyEmail:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(builder: (_) => VerifyEmailPage(email: email));
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
      case home:
      case medications:
      case adherence:
      case education:
      case settingsPage:
        final initialIndex = _getInitialIndexForRoute(settings.name);
        return MaterialPageRoute(
          builder: (_) => MainNavigationShell(initialIndex: initialIndex),
        );
      case caregivers:
        return MaterialPageRoute(builder: (_) => const CaregiverSupportPage());
      case addMedication:
        return MaterialPageRoute(builder: (_) => const AddEditMedicationPage());
      case editMedication:
        final med = settings.arguments as MedicationModel;
        return MaterialPageRoute(
          builder: (_) => AddEditMedicationPage(medication: med),
        );
      case medicationDetail:
        final med = settings.arguments as MedicationModel;
        return MaterialPageRoute(
          builder: (_) => MedicationDetailPage(medication: med),
        );
      case articleDetail:
        final article = settings.arguments as EducationContentModel;
        return MaterialPageRoute(
          builder: (_) => ArticleDetailPage(article: article),
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }

  static int _getInitialIndexForRoute(String? routeName) {
    switch (routeName) {
      case medications:
        return 1;
      case adherence:
        return 2;
      case education:
        return 3;
      case settingsPage:
        return 4;
      case home:
      default:
        return 0;
    }
  }
}
