# MedRemind — Mobile Medication Adherence Application

MedRemind is a fully functional Flutter mobile application designed to improve medication adherence among patients living with chronic non-communicable diseases (NCDs) such as hypertension, diabetes, HIV/AIDS, and epilepsy, particularly in low-resource settings like Rwanda.

The application combines personalized medication reminders, one-tap dose logging, real-time adherence tracking, caregiver support, and condition-specific health education. It is built with a clean architecture, BLoC state management, and a Firebase backend.

---

## Features

- *Authentication (2 methods)*
  - Email & Password registration with email verification gate
  - Password reset flow
  - One-tap Google Sign-In

- *Medications CRUD*
  - Create, Read, Update, and Delete medications
  - Dosage, frequency, custom time picker, inventory counter, and special instructions

- *Dose Logging & Adherence Tracking*
  - Interactive dose confirmation modal
  - Real-time progress ring on the Home Dashboard
  - Weekly adherence heatmap (Mon–Sun)

- *Caregiver Support*
  - Add and manage caregivers with status badges (Connected / Pending Invite)
  - One-tap Emergency Assistance alert

- *Health Education Library*
  - Condition-specific articles (Diabetes, Hypertension, HIV/AIDS, Mobility & Exercise)
  - Content loaded from Firestore (not hardcoded)

- *User Preferences (SharedPreferences)*
  - Language selection (English, Kinyarwanda, French, Swahili)
  - Font size scaling (Normal / Large)
  - Notification sound toggle
  - Offline mode indicator
  - All preferences persist across app restarts

---

## Architecture

The project follows *Flutter Clean Architecture* combined with the *BLoC* pattern:
lib/
├── core/                  # Theme, constants, router, services, validators
├── data/
│   ├── models/            # Plain Dart models + serialization
│   └── repositories/      # Firebase Auth & Firestore access
├── logic/                 # BLoCs and Cubits
│   ├── auth/
│   ├── medications/
│   ├── dose_logs/
│   ├── caregivers/
│   ├── education/
│   └── settings/
└── presentation/
├── pages/             # All screens
└── widgets/           # Reusable UI components
text*State Management*
- BLoC for complex/async flows (Auth, Medications, DoseLogs, Caregivers)
- Cubit for simple synchronous state (Settings, Education, Theme)

---

## Tech Stack

| Layer              | Technology                          |
|--------------------|-------------------------------------|
| Frontend           | Flutter                             |
| State Management   | flutter_bloc + equatable            |
| Backend            | Firebase Auth + Cloud Firestore     |
| Local Storage      | shared_preferences                  |
| Notifications      | flutter_local_notifications         |
| Testing            | bloc_test, mocktail, fake_cloud_firestore, firebase_auth_mocks |

---

## Database (Firestore Collections)

| Collection          | Description                              |
|---------------------|------------------------------------------|
| users             | User profiles and preferences            |
| medications       | Patient medication schedules             |
| dose_logs         | Taken / Missed / Skipped dose records    |
| caregivers        | Support network contacts                 |
| education_content | Read-only health education articles      |

---

## Firebase Security Rules (Summary)

- Users can only read/write their own data (request.auth.uid == userId)
- Medications, dose logs, and caregivers are owner-only
- Education content is readable by any authenticated user but write-protected

---

## Getting Started

### Prerequisites
- Flutter SDK (3.11 or higher)
- Android Studio / VS Code
- A physical Android device or emulator
- Firebase project configured (already included)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/nicolembera/MedRemind-Summative.git
cd MedRemind-Summative

# 2. Install dependencies
flutter pub get

# 3. Format and analyze (should report 0 issues)
dart format .
flutter analyze

# 4. Run the test suite
flutter test --coverage

# 5. Launch on a physical device or emulator
flutter run
Important: Web, desktop, and Chrome builds are not accepted for this course. Always run on a physical device or Android emulator.

Testing
The project includes 14 unit and widget tests with a 100% pass rate:

Unit Tests
AuthBloc state transitions (login, signup, logout, error handling)
MedicationModel serialization (toMap / fromMap / copyWith)
DoseLogRepository adherence percentage calculation

Widget Tests
Login form validation and error messages
Bottom navigation shell tab switching
Initial splash screen rendering


Run all tests with:
Bashflutter test --coverage

Project Structure Highlights

Clean separation of concerns (Presentation / Logic / Data)
Fully typed models with fromMap / toMap / copyWith
Real-time streams from Firestore
Responsive UI tested on different screen sizes and orientations
Multilingual support (English, Kinyarwanda, French, Swahili)


Known Limitations & Future Work

Notifications currently use local device scheduling only. Future versions will integrate Firebase Cloud Messaging (FCM) for remote caregiver alerts.
Offline mutations work, but full multi-device conflict resolution (CRDT) is planned for v2.0.
A clinician web portal for remote medication management is under consideration.