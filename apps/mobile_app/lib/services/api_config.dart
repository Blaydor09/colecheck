// No active imports needed since custom IP configurations are currently commented out.

class ApiConfig {
  /// Base URL for the Colecheck API (production).
  static const String baseUrl = 'https://colecheck.sisganadero.online/api/v1';
}
  /*static String get baseUrl {
    const port = '3005';

    if (kIsWeb) {
      return 'http://localhost:$port/api/v1';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$port/api/v1';
    }

    // iOS simulator, macOS, Windows, Linux
    return 'http://localhost:$port/api/v1';
  }
}
*/