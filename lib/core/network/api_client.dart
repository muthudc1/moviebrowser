import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';
import '../error/exceptions.dart';

class ApiClient {
  final http.Client _client;
  final Duration _timeout;

  ApiClient({http.Client? client, Duration timeout = const Duration(seconds: 15)})
      : _client = client ?? http.Client(),
        _timeout = timeout;

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, String>? customHeaders,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final headers = _buildHeaders(customHeaders);

      final response = await _client.get(uri, headers: headers).timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException('Network communication failure. Please check your connection.');
    } on TimeoutException {
      throw NetworkException('Request timed out. Please check your internet connection and try again.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error occurred: $e');
    }
  }

  Uri _buildUri(String endpoint, Map<String, String>? queryParams) {
    final baseUrl = EnvConfig.baseUrl;
    final Map<String, String> finalParams = {
      'api_key': EnvConfig.apiKey,
      if (queryParams != null) ...queryParams,
    };

    final isHttps = baseUrl.startsWith('https://');
    final hostAndPath = baseUrl.replaceFirst(RegExp(r'https?://'), '');
    final host = hostAndPath.split('/').first;
    final pathSegments = hostAndPath.split('/').sublist(1).join('/');

    final path = pathSegments.isEmpty ? endpoint : '/$pathSegments$endpoint';

    if (isHttps) {
      return Uri.https(host, path, finalParams);
    } else {
      return Uri.http(host, path, finalParams);
    }
  }

  Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    };

    if (EnvConfig.accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${EnvConfig.accessToken}';
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    dynamic decodedJson;
    try {
      if (responseBody.isNotEmpty) {
        decodedJson = jsonDecode(responseBody);
      }
    } catch (_) {
      decodedJson = null;
    }

    if (statusCode >= 200 && statusCode < 300) {
      return decodedJson;
    } else if (statusCode == 401) {
      final msg = decodedJson is Map ? decodedJson['status_message'] : null;
      throw UnauthorizedException(msg ?? 'Unauthorized request. Check your TMDB API Key or Access Token.');
    } else if (statusCode == 404) {
      final msg = decodedJson is Map ? decodedJson['status_message'] : null;
      throw NotFoundException(msg ?? 'Requested movie resource was not found.');
    } else if (statusCode >= 500) {
      throw ServerException('TMDB server error ($statusCode). Please try again later.', statusCode);
    } else {
      final msg = decodedJson is Map ? decodedJson['status_message'] : null;
      throw ServerException(msg ?? 'Request failed with status: $statusCode', statusCode);
    }
  }

  void close() {
    _client.close();
  }
}
