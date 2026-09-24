import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/api_constants.dart';

class EnvConfig {
  static String? _apiKey;
  static String? _accessToken;
  static String? _baseUrl;
  static String? _imageBaseUrl;

  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
      _apiKey = dotenv.env['TMDB_API_KEY'];
      _accessToken = dotenv.env['TMDB_ACCESS_TOKEN'];
      _baseUrl = dotenv.env['TMDB_BASE_URL'];
      _imageBaseUrl = dotenv.env['TMDB_IMAGE_BASE_URL'];
    } catch (e) {
      debugPrint('Warning: Could not load .env file: $e. Using fallback/in-memory configuration.');
    }
  }

  static String get apiKey => _apiKey ?? dotenv.env['TMDB_API_KEY'] ?? '';
  static String get accessToken => _accessToken ?? dotenv.env['TMDB_ACCESS_TOKEN'] ?? '';
  static String get baseUrl =>
      (_baseUrl?.isNotEmpty == true ? _baseUrl : dotenv.env['TMDB_BASE_URL']) ?? ApiConstants.defaultBaseUrl;
  static String get imageBaseUrl =>
      (_imageBaseUrl?.isNotEmpty == true ? _imageBaseUrl : dotenv.env['TMDB_IMAGE_BASE_URL']) ??
      ApiConstants.defaultImageBaseUrl;

  static bool get hasValidApiKey => apiKey.isNotEmpty && apiKey != 'your_tmdb_api_key_here';
}
