import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';

/// Centralized HTTP client with automatic JWT injection.
/// Equivalent to the web's `services/api.ts` (Axios instance).
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  // ── Token management ──────────────────────────────────────────────────

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  // ── Headers ───────────────────────────────────────────────────────────

  Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── HTTP helpers ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> get(String path) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await http.get(url, headers: await _headers());
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String path,
      [Map<String, dynamic>? body]) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await http.post(
      url,
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patch(String path,
      [Map<String, dynamic>? body]) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await http.patch(
      url,
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await http.delete(url, headers: await _headers());
    return _handleResponse(response);
  }

  // ── Response handling ─────────────────────────────────────────────────

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: body['message'] as String? ?? 'Error desconocido',
    );
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
