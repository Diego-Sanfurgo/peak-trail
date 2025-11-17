import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peak_trail/controllers/navigation_controller.dart';

import 'bloc/map_bloc.dart';

class HomeShellView extends StatefulWidget {
  const HomeShellView({super.key, required this.child});
  final Widget child;

  @override
  State<HomeShellView> createState() => _HomeShellViewState();
}

class _HomeShellViewState extends State<HomeShellView> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapBloc(),
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.map), label: "Mapa"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
          ],
          onTap: (index) {
            if (index == 0) {
              selectedIndex = 0;
              NavigationController.go(Routes.MAP);
            } else if (index == 1) {
              selectedIndex = 1;
              NavigationController.go(Routes.PROFILE);
            }
            setState(() {});
          },
        ),
      ),
    );
  }
}
