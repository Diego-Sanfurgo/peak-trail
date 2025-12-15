class Environment {
  static const String mapboxToken = String.fromEnvironment(
    'MAPBOX_TOKEN',
    defaultValue: '',
  );
}
