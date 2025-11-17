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

class AppConstants {
  static const String mountainsSourceId = 'mountains-source';
  static const String mountainMarkerId = 'mountain-marker';
  static const String clusterLayerId = 'cluster-layer';
  static const String clusterCountId = 'cluster-count';
  static const String singlePointId = 'unclustered-points';

}
