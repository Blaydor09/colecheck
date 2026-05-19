import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

/// User model matching the API response shape.
class AppUser {
  final String id;
  final String? email;
  final String? fullName;
  final String? schoolId;
  final List<String> roles;

  AppUser({
    required this.id,
    this.email,
    this.fullName,
    this.schoolId,
    this.roles = const [],
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final rolesList = (json['roles'] as List<dynamic>?)
            ?.map((r) => r.toString())
            .toList() ??
        [];

    return AppUser(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String?,
      fullName: json['full_name'] as String?,
      schoolId: (json['school_id'] ?? json['schoolId'])?.toString(),
      roles: rolesList,
    );
  }

  bool get isGuardian => roles.contains('guardian');
  bool get isTeacher =>
      roles.contains('teacher') || roles.contains('attendance_staff');

  /// First name for greeting: "Hola, Carlos"
  String get firstName => (fullName ?? 'Usuario').split(' ').first;
}

/// Authentication state provider — mirrors the web's AuthContext.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AppUser? _user;
  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _errorMessage;

  AppUser? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Try to restore a previous session from stored token.
  Future<void> tryRestoreSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final hasToken = await _authService.hasToken();
      if (!hasToken) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _authService.getMe();
      final userData = response['user'] ?? response['data'];

      if (response['success'] == true && userData != null) {
        _user = AppUser.fromJson(userData as Map<String, dynamic>);
        _isAuthenticated = true;
      } else {
        await _authService.logout();
      }
    } catch (e) {
      debugPrint('Session restore failed: $e');
      await _authService.logout();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Login with email/DNI + password.
  Future<bool> login(String identifier, String password) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.login(identifier, password);

      if (response['success'] == true) {
        final userData = response['user'] ?? response['data'];
        if (userData != null) {
          _user = AppUser.fromJson(userData as Map<String, dynamic>);
          _isAuthenticated = true;
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      _errorMessage = response['message'] as String? ?? 'Error al iniciar sesión';
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'No se pudo conectar con el servidor';
      debugPrint('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Logout — clear token and state.
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }
}
