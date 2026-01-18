class Environment {
  static const String mapboxToken = String.fromEnvironment(
    'MAPBOX_TOKEN',
    defaultValue: '',
  );

  static const String supabaseSecret = String.fromEnvironment(
    'SUPABASE_SECRET',
    defaultValue: '',
  );
  static const String supabaseURL = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabasePublishable = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE',
    defaultValue: '',
  );
}
