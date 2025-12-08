import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:peak_trail/tracking/tracking_database.dart';
import 'package:peak_trail/utils/constant_and_variables.dart';
import '../views/location_debug_test.dart';
import 'route_widgets_export.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    navigatorKey: AppUtil.navigatorKey,
    initialLocation: "/map",
    observers: [],
    routes: [
      ShellRoute(
        navigatorKey: GlobalKey<NavigatorState>(),
        builder: (context, state, child) {
          return HomeShellView(child: child);
        },
        routes: [
          GoRoute(path: "/map", builder: (context, state) => const MapView()),
          GoRoute(
            path: "/profile",
            // builder: (context, state) => const ProfileView(),
            builder: (context, state) =>
                LocationDebugScreen(database: TrackingDatabase()),
          ),
        ],
      ),
      GoRoute(path: "/", redirect: (context, state) => '/map'),
    ],
  );
}
