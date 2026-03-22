import 'package:flutter/material.dart';
import 'wheel_segment.dart';

class SharedWheelSummary {
  final String shareCode;
  final String name;
  final int spinCount;
  final DateTime expiresAt;
  final List<WheelSegment> segments;

  SharedWheelSummary({
    required this.shareCode,
    required this.name,
    required this.spinCount,
    required this.expiresAt,
    required this.segments,
  });

  factory SharedWheelSummary.fromJson(Map<String, dynamic> json) {
    return SharedWheelSummary(
      shareCode: json['share_code'],
      name: json['name'],
      spinCount: json['spin_count'] ?? 0,
      expiresAt: DateTime.parse(json['expires_at']),
      segments: (json['segments'] as List<dynamic>?)
              ?.map((e) => WheelSegment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
