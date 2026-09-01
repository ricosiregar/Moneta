import 'package:shared_preferences/shared_preferences.dart';

/// Data class holding saved login credentials
class SavedCredentials {
  final String email;
  final String password;

  const SavedCredentials({
    required this.email,
    required this.password,
  });
}

/// Abstract contract for local key-value storage in Moneta
abstract class AppLocalStorage {
  /// Save user email and password for quick re-login
  Future<void> saveCredentials({
    required String email,
    required String password,
    required bool rememberMe,
  });

  /// Retrieve saved credentials if remember me was active
  SavedCredentials? getSavedCredentials();

  /// Check if remember me is active
  bool isRememberMeEnabled();

  /// Clear saved email and password
  Future<void> clearSavedCredentials();
}

class AppLocalStorageImpl implements AppLocalStorage {
  final SharedPreferences sharedPreferences;

  static const String _keySavedEmail = 'saved_email';
  static const String _keySavedPassword = 'saved_password';
  static const String _keyRememberMe = 'remember_me';

  AppLocalStorageImpl({required this.sharedPreferences});

  @override
  Future<void> saveCredentials({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    await sharedPreferences.setBool(_keyRememberMe, rememberMe);
    if (rememberMe) {
      await sharedPreferences.setString(_keySavedEmail, email);
      await sharedPreferences.setString(_keySavedPassword, password);
    } else {
      await sharedPreferences.remove(_keySavedEmail);
      await sharedPreferences.remove(_keySavedPassword);
    }
  }

  @override
  SavedCredentials? getSavedCredentials() {
    final isRemembered = sharedPreferences.getBool(_keyRememberMe) ?? false;
    final email = sharedPreferences.getString(_keySavedEmail);
    final password = sharedPreferences.getString(_keySavedPassword);

    if (isRemembered && email != null && password != null && email.isNotEmpty) {
      return SavedCredentials(email: email, password: password);
    }
    return null;
  }

  @override
  bool isRememberMeEnabled() {
    return sharedPreferences.getBool(_keyRememberMe) ?? true;
  }

  @override
  Future<void> clearSavedCredentials() async {
    await sharedPreferences.remove(_keySavedEmail);
    await sharedPreferences.remove(_keySavedPassword);
    await sharedPreferences.setBool(_keyRememberMe, false);
  }
}
