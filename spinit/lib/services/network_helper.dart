import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'session_service.dart';

class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  NetworkException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class NetworkHelper {
  static Future<dynamic> processResponse(http.Response response) async {
    final body = json.decode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body['success'] == true) {
        return body['data'];
      }
      throw NetworkException(body['error']?.toString() ?? 'Something went wrong');
    }

    switch (response.statusCode) {
      case 401:
        // Try to reset session on unauthorized
        await sessionService.resetSession();
        throw NetworkException('Session expired. Please try again.', statusCode: 401);
      case 404:
        throw NetworkException('Wheel code not found or expired.', statusCode: 404);
      case 429:
        throw NetworkException('Slow down! Too many requests.', statusCode: 429);
      case 500:
      default:
        throw NetworkException('Server error. Please try again later.', statusCode: response.statusCode);
    }
  }

  static Future<dynamic> handleRequest(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(const Duration(seconds: 10));
      return await processResponse(response);
    } on SocketException {
      throw NetworkException("You're offline. Please check your connection.");
    } on http.ClientException {
      throw NetworkException("Connection failed. Server might be down.");
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw NetworkException('Request timed out or failed: $e');
    }
  }
}
