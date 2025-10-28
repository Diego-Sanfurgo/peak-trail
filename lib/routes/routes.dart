import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:peak_trail/utils/constant_and_variables.dart';
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
            builder: (context, state) => const ProfileView(),
          ),
        ],
      ),
      GoRoute(path: "/", redirect: (context, state) => '/map'),
      GoRoute(path: "/profile", builder: (context, state) => const HomeView()),
    ],
  );
}
