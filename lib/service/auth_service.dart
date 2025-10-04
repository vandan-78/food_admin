import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _emailKey = 'email';
  static const String _rememberMeKey = 'rememberMe';

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Login user
  static Future<void> login({required String email, bool rememberMe = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_emailKey, email);
    await prefs.setBool(_rememberMeKey, rememberMe);
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);

    // Only clear email if "Remember Me" was not checked
    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
    if (!rememberMe) {
      await prefs.remove(_emailKey);
    }
    await prefs.remove(_rememberMeKey);
  }

  // Get saved email
  static Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  // Check if remember me was enabled
  static Future<bool> wasRememberMeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }
}