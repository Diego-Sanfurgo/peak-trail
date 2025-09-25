// ignore_for_file: constant_identifier_names

import 'package:go_router/go_router.dart';

import '../utils/constant_and_variables.dart';

class NavigationController {
  static void go(
    Routes route, {
    dynamic extra,
    Uri? actualUri,
    String? pathParameter,
    Map<String, String>? parameters,
  }) {
    String path = actualUri == null
        ? _getPath(route, parameter: pathParameter)
        : Uri(
            path: actualUri.path + _getPath(route, parameter: pathParameter),
            queryParameters: {...actualUri.queryParameters, ...?parameters},
          ).toString();

    AppUtil.navigatorContext.go(path, extra: extra);
  }
}

enum Routes { HOME, MAP, PROFILE }

String _getPath(Routes route, {String? parameter}) {
  switch (route) {
    case Routes.HOME:
      return '/home';
    case Routes.MAP:
      return '/map';
    case Routes.PROFILE:
      return '/profile';
  }
}
