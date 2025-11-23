import 'package:flutter/material.dart';
import 'package:peak_trail/routes/routes.dart';

import 'controllers/location_service.dart';
import 'utils/constant_and_variables.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocationService.instance.init();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      color: Colors.green,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: AppUtil.scaffoldKey,
    );
  }
}
