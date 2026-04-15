import 'dart:io';

/// Utility class to check internet connectivity
class ConnectivityChecker {
  ConnectivityChecker._internal();
  static final ConnectivityChecker _instance = ConnectivityChecker._internal();
  factory ConnectivityChecker() => _instance;

  /// Check if device has internet connection
  /// Returns true if connected, false otherwise
  static Future<bool> hasInternetConnection() async {
    try {
      // Try to reach a reliable server with short timeout
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Check connection and throw error if no connection
  static Future<void> checkConnection() async {
    final hasConnection = await hasInternetConnection();
    if (!hasConnection) {
      throw Exception('No internet connection. Please check your network.');
    }
  }
}
