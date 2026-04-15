import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Custom exception thrown by ApiClient for all error cases.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException({required this.message, this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

/// Singleton HTTP client for all BioXplora API calls.
///
/// Usage:
///   final client = ApiClient();
///   final data = await client.get('/internships');
///   final data = await client.post('/auth/login', body: {...}, requiresAuth: false);
class ApiClient {
  ApiClient._internal();
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  /// For local dev: 'http://localhost/elearning/api' (Web/Desktop)
  /// For Android emulator: 'http://10.0.2.2/elearning/api'
  /// For physical device: 'http://your-computer-ip/elearning/api'
  static const String baseUrl = 'http://localhost/elearning/api';

  static const Duration _timeout = Duration(seconds: 60);

  final _storage = const FlutterSecureStorage();
  final http.Client _httpClient = http.Client();

  // ─── Token helpers ───────────────────────────────────────────────────────

  Future<String?> getToken() => _storage.read(key: 'auth_token');

  Future<void> saveToken(String token) =>
      _storage.write(key: 'auth_token', value: token);

  Future<void> clearToken() => _storage.delete(key: 'auth_token');

  // ─── Header builder ──────────────────────────────────────────────────────

  Map<String, String> _buildHeaders({bool requiresAuth = true, String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (requiresAuth && token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── Response parser ─────────────────────────────────────────────────────

  Map<String, dynamic> _parseResponse(http.Response response) {
    final body = utf8.decode(response.bodyBytes);
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      return jsonDecode(body) as Map<String, dynamic>;
    }

    // Try to extract server error message
    String message = 'Something went wrong';
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      message = decoded['message'] as String? ?? message;
    } catch (_) {}

    if (statusCode == 401) {
      throw ApiException(message: 'Unauthorized. Please login again.', statusCode: 401);
    } else if (statusCode == 403) {
      throw ApiException(message: 'Account not verified. Please verify your email.', statusCode: 403);
    } else if (statusCode == 404) {
      throw ApiException(message: 'Resource not found.', statusCode: 404);
    } else if (statusCode == 409) {
      throw ApiException(message: message, statusCode: 409);
    } else if (statusCode == 422) {
      throw ApiException(message: message, statusCode: 422);
    } else {
      throw ApiException(message: message, statusCode: statusCode);
    }
  }

  // ─── HTTP Methods ─────────────────────────────────────────────────────────

  /// GET request. Attach [queryParams] for URL query string.
  Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requiresAuth = true,
    Map<String, String>? queryParams,
  }) async {
    try {
      final token = requiresAuth ? await getToken() : null;
      var uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }
      final response = await _httpClient
          .get(uri, headers: _buildHeaders(requiresAuth: requiresAuth, token: token))
          .timeout(_timeout);
      return _parseResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection. Please check your network.');
    } on HttpException {
      throw ApiException(message: 'Network error occurred. Please try again.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Unexpected error: $e');
    }
  }

  /// POST request with JSON [body].
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic> body = const {},
    bool requiresAuth = true,
  }) async {
    try {
      final token = requiresAuth ? await getToken() : null;
      final uri = Uri.parse('$baseUrl$endpoint');
      
      print('--- API REQUEST ---');
      print('URL: $uri');
      print('Headers: ${_buildHeaders(requiresAuth: requiresAuth, token: token)}');
      print('Body: ${jsonEncode(body)}');
      
      final response = await _httpClient
          .post(
            uri,
            headers: _buildHeaders(requiresAuth: requiresAuth, token: token),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      
      print('--- API RESPONSE ---');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      
      return _parseResponse(response);
    } on SocketException {
      print('--- API ERROR: SocketException (No internet) ---');
      throw ApiException(message: 'No internet connection. Please check your network.');
    } on HttpException {
      print('--- API ERROR: HttpException ---');
      throw ApiException(message: 'Network error occurred. Please try again.');
    } on ApiException catch (e) {
      print('--- API ERROR: ApiException: ${e.message} ---');
      rethrow;
    } catch (e) {
      print('--- API ERROR: $e ---');
      throw ApiException(message: 'Unexpected error: $e');
    }
  }

  /// DELETE request.
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final token = requiresAuth ? await getToken() : null;
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await _httpClient
          .delete(uri, headers: _buildHeaders(requiresAuth: requiresAuth, token: token))
          .timeout(_timeout);
      return _parseResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection. Please check your network.');
    } on HttpException {
      throw ApiException(message: 'Network error occurred. Please try again.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Unexpected error: $e');
    }
  }

  /// Multipart POST for file uploads (e.g. profile image).
  /// [fileFieldName] is the form field name, [filePath] is the local file path.
  Future<Map<String, dynamic>> multipart(
    String endpoint, {
    Map<String, String> fields = const {},
    required String fileFieldName,
    required String filePath,
    bool requiresAuth = true,
  }) async {
    try {
      final token = requiresAuth ? await getToken() : null;
      final uri = Uri.parse('$baseUrl$endpoint');

      final request = http.MultipartRequest('POST', uri);
      if (requiresAuth && token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      fields.forEach((k, v) => request.fields[k] = v);
      request.files.add(await http.MultipartFile.fromPath(fileFieldName, filePath));

      final streamed = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamed);
      return _parseResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection. Please check your network.');
    } on HttpException {
      throw ApiException(message: 'Network error occurred. Please try again.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Unexpected error: $e');
    }
  }
}
