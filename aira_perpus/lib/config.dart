class AppConfig {
  static const String supabaseUrl = 'https://jnfasfcbtonkdhsoupmm.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpuZmFzZmNidG9ua2Roc291cG1tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODExNDYyOTcsImV4cCI6MjA5NjcyMjI5N30.fUqpYsb8zpMHhCkGNCA5kv-Rp9sl78t_T8nBlKHHOKM';
  
  static const String defaultSupabaseUrl = 'https://jnfasfcbtonkdhsoupmm.supabase.co';
  static const String defaultSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpuZmFzZmNidG9ua2Roc291cG1tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODExNDYyOTcsImV4cCI6MjA5NjcyMjI5N30.fUqpYsb8zpMHhCkGNCA5kv-Rp9sl78t_T8nBlKHHOKM';
  
  static bool get isConfigured => supabaseUrl.isNotEmpty;
  
  static Future<void> loadCustomConfigs() async {}
  static Future<void> clearCustomConfigs() async {}
  static Future<void> saveCustomConfigs(String url, String key) async {}
}
