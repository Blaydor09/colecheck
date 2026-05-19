import 'api_service.dart';

/// Authentication service — mirrors the web's AuthContext login/me/logout flow.
class AuthService {
  final ApiService _api = ApiService();

  /// POST /auth/login
  /// Returns the full response body: { success, token, user, data }
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final response = await _api.post('/auth/login', {
      'email': identifier,
      'password': password,
    });

    if (response['success'] == true && response['token'] != null) {
      await _api.saveToken(response['token'] as String);
    }

    return response;
  }

  /// GET /auth/me — verify current session
  Future<Map<String, dynamic>> getMe() async {
    return await _api.get('/auth/me');
  }

  /// Clear token from secure storage
  Future<void> logout() async {
    await _api.deleteToken();
  }

  /// Check if a stored token exists
  Future<bool> hasToken() async {
    final token = await _api.getToken();
    return token != null && token.isNotEmpty;
  }
}
