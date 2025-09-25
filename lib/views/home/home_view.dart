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
