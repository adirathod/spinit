import '../models/wheel_segment.dart';

class PresetPack {
  final String id;
  final String name;
  final String icon;
  final List<WheelSegment> segments;

  const PresetPack({
    required this.id,
    required this.name,
    required this.icon,
    required this.segments,
  });
}
