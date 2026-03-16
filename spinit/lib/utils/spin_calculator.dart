import 'dart:math';
import 'package:flutter/material.dart';
import '../models/wheel_segment.dart';

/// The pointer is fixed at the TOP of the wheel.
/// The wheel starts painting segments clockwise from the top (-π/2).
/// After rotating by [totalAngle] radians clockwise, we determine
/// which segment is now at the top.
WheelSegment getWinningSegment(double totalAngle, List<WheelSegment> segments) {
  if (segments.isEmpty) {
    return const WheelSegment(label: '', color: Color(0xFFFFFFFF));
  }
  final count = segments.length;
  final segmentAngle = 2 * pi / count;

  // Normalize the accumulated rotation into [0, 2π)
  final normalized = totalAngle % (2 * pi);

  // The wheel is painted starting at -π/2 (top), going clockwise.
  // After rotating normalized radians clockwise, the pointer at the top
  // now aligns with the segment that was originally at normalized radians
  // counter-clockwise from the top, i.e. at offset (2π - normalized).
  final pointerAngle = (2 * pi - normalized) % (2 * pi);
  final index = (pointerAngle / segmentAngle).floor() % count;
  return segments[index];
}
