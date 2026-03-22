import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wheel_segment.dart';
import '../models/share_result.dart';
import '../models/shared_wheel_summary.dart';
import 'network_helper.dart';
import 'session_service.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:8080/v1';
  
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<Map<String, String>> _getHeaders() async {
    final jwt = await sessionService.getJwt();
    return {
      'Content-Type': 'application/json',
      if (jwt != null) 'Authorization': 'Bearer $jwt',
    };
  }

  Future<ShareResult> shareWheel(String name, List<WheelSegment> segments) async {
    final headers = await _getHeaders();
    final response = await NetworkHelper.handleRequest(() => http.post(
      Uri.parse('$_baseUrl/wheels'),
      headers: headers,
      body: json.encode({
        'name': name,
        'segments': segments.map((s) => s.toJson()).toList(),
      }),
    ));

    return ShareResult.fromJson(response['wheel']);
  }

  Future<SharedWheelSummary> fetchWheel(String code) async {
    final response = await NetworkHelper.handleRequest(() => http.get(
      Uri.parse('$_baseUrl/wheels/$code'),
    ));

    return SharedWheelSummary.fromJson(response);
  }

  Future<List<SharedWheelSummary>> getMySharedWheels() async {
    final headers = await _getHeaders();
    final response = await NetworkHelper.handleRequest(() => http.get(
      Uri.parse('$_baseUrl/wheels/my'),
      headers: headers,
    ));

    final list = response as List<dynamic>;
    return list.map((e) => SharedWheelSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> deleteWheel(String code) async {
    final headers = await _getHeaders();
    await NetworkHelper.handleRequest(() => http.delete(
      Uri.parse('$_baseUrl/wheels/$code'),
      headers: headers,
    ));
  }

  Future<void> logSpin(String code, String label, String color) async {
    await NetworkHelper.handleRequest(() => http.post(
      Uri.parse('$_baseUrl/wheels/$code/spin'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'result_label': label,
        'result_color': color,
      }),
    ));
  }
}

final apiService = ApiService();
