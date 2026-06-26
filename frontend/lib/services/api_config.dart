import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }

    if (Platform.isIOS) {
      return 'http://127.0.0.1:3000';
    }

    return 'http://localhost:3000';
  }
}
