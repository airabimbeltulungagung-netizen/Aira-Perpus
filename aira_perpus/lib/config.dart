import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static String _customUrl = "";
  static String _customAnonKey = "";

  static const String defaultSupabaseUrl =
      "";
  static const String defaultSupabaseAnonKey =
      "";

  static String get supabaseUrl =>
      _customUrl.isNotEmpty ? _customUrl : defaultSupabaseUrl;
  static String get supabaseAnonKey =>
      _customAnonKey.isNotEmpty ? _customAnonKey : defaultSupabaseAnonKey;

  // Deteksi sistem apakah creds sudah diganti dari nilai placeholder bawaan
  static bool get isConfigured =>
      supabaseUrl != defaultSupabaseUrl && supabaseAnonKey.isNotEmpty;

  static Future<void> loadCustomConfigs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _customUrl = prefs.getString('custom_supabase_url') ?? "";
      _customAnonKey = prefs.getString('custom_supabase_anon_key') ?? "";
    } catch (_) {}
  }

  static Future<void> saveCustomConfigs(String url, String key) async {
    _customUrl = url.trim();
    _customAnonKey = key.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_supabase_url', _customUrl);
      await prefs.setString('custom_supabase_anon_key', _customAnonKey);
    } catch (_) {}
  }

  static Future<void> clearCustomConfigs() async {
    _customUrl = "";
    _customAnonKey = "";
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('custom_supabase_url');
      await prefs.remove('custom_supabase_anon_key');
    } catch (_) {}
  }
}
