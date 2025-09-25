import 'package:flutter/material.dart';

class AppUtil {
  static final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext get navigatorContext =>
      navigatorKey.currentContext ?? scaffoldKey.currentContext!;

  static BuildContext get scaffoldContext =>
      scaffoldKey.currentContext as BuildContext;
}
