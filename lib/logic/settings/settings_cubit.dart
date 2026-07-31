import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/services/shared_prefs_service.dart';

class SettingsState extends Equatable {
  final String language;
  final String fontSize; // 'Normal', 'Large', 'Extra Large'
  final bool notificationSounds;
  final bool offlineMode;

  const SettingsState({
    required this.language,
    required this.fontSize,
    required this.notificationSounds,
    required this.offlineMode,
  });

  double get fontScale {
    switch (fontSize) {
      case 'Large':
        return 1.25;
      case 'Extra Large':
        return 1.45;
      case 'Normal':
      default:
        return 1.0;
    }
  }

  SettingsState copyWith({
    String? language,
    String? fontSize,
    bool? notificationSounds,
    bool? offlineMode,
  }) {
    return SettingsState(
      language: language ?? this.language,
      fontSize: fontSize ?? this.fontSize,
      notificationSounds: notificationSounds ?? this.notificationSounds,
      offlineMode: offlineMode ?? this.offlineMode,
    );
  }

  @override
  List<Object?> get props => [
    language,
    fontSize,
    notificationSounds,
    offlineMode,
  ];
}

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPrefsService _prefsService;

  SettingsCubit(this._prefsService)
    : super(
        SettingsState(
          language: _prefsService.language,
          fontSize: _prefsService.fontSize,
          notificationSounds: _prefsService.notificationSounds,
          offlineMode: _prefsService.offlineMode,
        ),
      );

  Future<void> changeLanguage(String newLang) async {
    await _prefsService.setLanguage(newLang);
    emit(state.copyWith(language: newLang));
  }

  Future<void> changeFontSize(String newSize) async {
    await _prefsService.setFontSize(newSize);
    emit(state.copyWith(fontSize: newSize));
  }

  Future<void> toggleNotificationSounds(bool enabled) async {
    await _prefsService.setNotificationSounds(enabled);
    emit(state.copyWith(notificationSounds: enabled));
  }

  Future<void> toggleOfflineMode(bool enabled) async {
    await _prefsService.setOfflineMode(enabled);
    emit(state.copyWith(offlineMode: enabled));
  }
}
