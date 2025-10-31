import 'package:flutter/material.dart';
import 'package:peak_trail/controllers/navigation_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home View')),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welcome to the Home View!'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    NavigationController.go(Routes.MAP);
                  },
                  child: Text('Go to Map View'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeShellView extends StatefulWidget {
  final Widget child;
  const HomeShellView({super.key, required this.child});

  @override
  State<HomeShellView> createState() => _HomeShellViewState();
}

class _HomeShellViewState extends State<HomeShellView> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
