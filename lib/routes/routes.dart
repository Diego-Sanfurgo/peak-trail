import 'package:go_router/go_router.dart';
import 'package:peak_trail/utils/constant_and_variables.dart';
import 'route_widgets_export.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    navigatorKey: AppUtil.navigatorKey,
    initialLocation: "/",
    observers: [],
    routes: [
      GoRoute(path: "/", redirect: (context, state) => '/home'),
      GoRoute(path: "/home", builder: (context, state) => const HomeView()),
      GoRoute(path: "/map", builder: (context, state) => const MapView()),
    ],
  );
}
