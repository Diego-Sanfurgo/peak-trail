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

class MapConstants {
  static const String waterfallID = 'waterfall';
  static const String peakID = 'peak';
  static const String mountainPassID = 'pass';
  static const String lakeID = 'lake';

  static const String trackingSourceID = "tracking-source";
  static const String trackingLayerID = "tracking-layer";
  static const String trackingFeatureID = "tracking-feature";
}
