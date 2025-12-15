import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:peak_trail/data/repositories/peaks_repository.dart';
import 'package:peak_trail/utils/constant_and_variables.dart';
import 'package:peak_trail/persistence/tracking/tracking_database.dart';
import 'route_widgets_export.dart';

// Asegúrate de importar tu HomeShellView correctamente

class AppRouter {
  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    navigatorKey: AppUtil.navigatorKey,
    initialLocation: "/map",
    routes: [
      GoRoute(path: "/", redirect: (context, state) => '/map'),

      // CAMBIO PRINCIPAL: Usar StatefulShellRoute
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // Pasamos el navigationShell al HomeShellView en lugar del child genérico
          return HomeShellView(navigationShell: navigationShell);
        },
        branches: [
          // RAMA 1: Mapa
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/map",
                builder: (context, state) => const MapView(),
                routes: [
                  GoRoute(
                    path: '/search',
                    builder: (context, state) => RepositoryProvider(
                      create: (context) => PeaksRepository(),
                      child: const SearchView(),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // RAMA 2: Perfil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/profile",
                builder: (context, state) =>
                    LocationDebugScreen(database: TrackingDatabase()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
