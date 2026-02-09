import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peak_trail/features/settings/bloc/settings_bloc.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
        actions: [
          IconButton(
            onPressed: () {
              context.read<SettingsBloc>().add(ToggleTheme());
            },
            icon: BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                return Icon(state.isDarkMode ? Icons.dark_mode : Icons.sunny);
              },
            ),
          ),
        ],
      ),
      body: const Center(child: Placeholder(child: Text("Perfil increíble"))),
    );
  }
}
