import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  /// Base URL for the Colecheck API.
  /// - Android Emulator uses 10.0.2.2 to reach host localhost.
  /// - iOS Simulator / Web / Desktop use localhost directly.
  static String get baseUrl {
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
