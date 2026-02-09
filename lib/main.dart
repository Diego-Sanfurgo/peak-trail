import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:peak_trail/core/theme/theme.dart';
import 'package:peak_trail/core/router/app_router.dart';
import 'package:peak_trail/data/providers/settings_provider.dart';
import 'package:peak_trail/data/repositories/settings_repository.dart';
import 'package:peak_trail/features/settings/bloc/settings_bloc.dart';

import 'core/utils/constant_and_variables.dart';

import 'package:peak_trail/init.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initApp();
  final prefs = await SharedPreferences.getInstance();
  final settingsRepository = SettingsRepository(SettingsProvider(prefs));

  runApp(App(settingsRepository: settingsRepository));
}

class App extends StatelessWidget {
  final SettingsRepository settingsRepository;

  const App({super.key, required this.settingsRepository});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: settingsRepository,
      child: BlocProvider(
        create: (context) =>
            SettingsBloc(settingsRepository: settingsRepository)
              ..add(LoadTheme()),
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return MaterialApp.router(
              routerConfig: AppRouter.router,
              debugShowCheckedModeBanner: false,
              scaffoldMessengerKey: AppUtil.scaffoldKey,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            );
          },
        ),
      ),
    );
  }
}
