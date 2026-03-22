import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'network_helper.dart';

class SessionService {
  static const String _baseUrl = 'http://localhost:8080/v1'; // Change for production
  static const String _kDeviceTokenKey = 'device_token';
  static const String _kJwtKey = 'jwt_token';
  
  final _storage = const FlutterSecureStorage();
  
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  Future<void> initSession() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceToken = prefs.getString(_kDeviceTokenKey);
    
    if (deviceToken == null) {
      deviceToken = const Uuid().v4();
      await prefs.setString(_kDeviceTokenKey, deviceToken);
    }

    // Try to get existing JWT
    String? jwt = await _storage.read(key: _kJwtKey);
    if (jwt == null) {
      await _fetchNewSession(deviceToken);
    }
  }

  Future<void> _fetchNewSession(String deviceToken) async {
    final response = await NetworkHelper.handleRequest(() => http.post(
      Uri.parse('$_baseUrl/session'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'device_token': deviceToken}),
    ));

    final jwt = response['jwt_token'] as String;
    await _storage.write(key: _kJwtKey, value: jwt);
  }

  Future<String?> getJwt() async {
    return await _storage.read(key: _kJwtKey);
  }

  Future<void> resetSession() async {
    await _storage.delete(key: _kJwtKey);
    final prefs = await SharedPreferences.getInstance();
    final deviceToken = prefs.getString(_kDeviceTokenKey);
    if (deviceToken != null) {
      await _fetchNewSession(deviceToken);
    }
  }
}

final sessionService = SessionService();
