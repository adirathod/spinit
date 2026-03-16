import 'package:flutter/material.dart';

class WheelSegment {
  final String label;
  final Color color;

  const WheelSegment({required this.label, required this.color});

  WheelSegment copyWith({String? label, Color? color}) {
    return WheelSegment(
      label: label ?? this.label,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'color': color.toARGB32(),
      };

  factory WheelSegment.fromJson(Map<String, dynamic> json) => WheelSegment(
        label: json['label'] as String,
        color: Color(json['color'] as int),
      );
}
