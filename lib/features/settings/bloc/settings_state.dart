part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final bool isDarkMode;

  const SettingsState({required this.isDarkMode});

  factory SettingsState.initial() {
    return const SettingsState(isDarkMode: true);
  }

  SettingsState copyWith({bool? isDarkMode}) {
    return SettingsState(isDarkMode: isDarkMode ?? this.isDarkMode);
  }

  @override
  List<Object> get props => [isDarkMode];
}
