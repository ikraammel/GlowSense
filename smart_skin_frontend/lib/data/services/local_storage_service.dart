import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final SharedPreferences prefs;
  LocalStorageService({required this.prefs});

  Future<void> saveTokens(String access, String refresh) async {
    await prefs.setString(_accessTokenKey, access);
    await prefs.setString(_refreshTokenKey, refresh);
  }

  String? getAccessToken() => prefs.getString(_accessTokenKey);
  String? getRefreshToken() => prefs.getString(_refreshTokenKey);

  Future<void> clearTokens() async {
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}
