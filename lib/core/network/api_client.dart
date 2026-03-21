import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException({required this.message, this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class ApiClient {
  ApiClient._internal();
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  // TODO: Replace with actual base URL
  static const String baseUrl = 'https://api.bioxplora.com/api/v1';
  static const Duration _timeout = Duration(seconds: 30);

  final _storage = const FlutterSecureStorage();
  final http.Client _client = http.Client();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }

  Map<String, String> _buildHeaders({bool requiresAuth = true, String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requiresAuth && token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    final body = utf8.decode(response.bodyBytes);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(body) as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      throw ApiException(message: 'Unauthorized. Please login again.', statusCode: 401);
    } else if (response.statusCode == 422) {
      final decoded = jsonDecode(body);
      final message = decoded['message'] ?? 'Validation error';
      throw ApiException(message: message.toString(), statusCode: 422);
    } else {
      final decoded = jsonDecode(body);
      final message = decoded['message'] ?? 'Something went wrong';
      throw ApiException(message: message.toString(), statusCode: response.statusCode);
    }
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requiresAuth = true,
    Map<String, String>? queryParams,
  }) async {
    try {
      final token = requiresAuth ? await _getToken() : null;
      var uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }
      final response = await _client
          .get(uri, headers: _buildHeaders(requiresAuth: requiresAuth, token: token))
          .timeout(_timeout);
      return _parseResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection');
    } on HttpException {
      throw ApiException(message: 'Network error occurred');
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requiresAuth = true,
  }) async {
    try {
      final token = requiresAuth ? await _getToken() : null;
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await _client
          .post(
            uri,
            headers: _buildHeaders(requiresAuth: requiresAuth, token: token),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _parseResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection');
    } on HttpException {
      throw ApiException(message: 'Network error occurred');
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requiresAuth = true,
  }) async {
    try {
      final token = requiresAuth ? await _getToken() : null;
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await _client
          .put(
            uri,
            headers: _buildHeaders(requiresAuth: requiresAuth, token: token),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _parseResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection');
    } on HttpException {
      throw ApiException(message: 'Network error occurred');
    }
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final token = requiresAuth ? await _getToken() : null;
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await _client
          .delete(uri, headers: _buildHeaders(requiresAuth: requiresAuth, token: token))
          .timeout(_timeout);
      return _parseResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection');
    } on HttpException {
      throw ApiException(message: 'Network error occurred');
    }
  }
}
