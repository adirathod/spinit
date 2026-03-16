import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wheel_segment.dart';
import '../utils/colors.dart';

const String _kSegmentsKey = 'wheel_segments';
const String _kWheelNameKey = 'wheel_name';

final List<WheelSegment> _kDefaultSegments = [
  WheelSegment(label: 'Pizza 🍕', color: kWheelPalette[0]),
  WheelSegment(label: 'Burger 🍔', color: kWheelPalette[1]),
  WheelSegment(label: 'Sushi 🍣', color: kWheelPalette[2]),
  WheelSegment(label: 'Tacos 🌮', color: kWheelPalette[3]),
  WheelSegment(label: 'Pasta 🍝', color: kWheelPalette[4]),
  WheelSegment(label: 'Salad 🥗', color: kWheelPalette[5]),
];

class WheelState {
  final String name;
  final List<WheelSegment> segments;

  const WheelState({required this.name, required this.segments});

  WheelState copyWith({String? name, List<WheelSegment>? segments}) {
    return WheelState(
      name: name ?? this.name,
      segments: segments ?? this.segments,
    );
  }
}

class WheelNotifier extends StateNotifier<WheelState> {
  WheelNotifier()
      : super(WheelState(name: 'What to Eat?', segments: _kDefaultSegments)) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final rawName = prefs.getString(_kWheelNameKey) ?? 'What to Eat?';
    final rawData = prefs.getString(_kSegmentsKey);

    List<WheelSegment> loadedSegments = _kDefaultSegments;

    if (rawData != null) {
      try {
        final List<dynamic> decoded = jsonDecode(rawData) as List<dynamic>;
        final segments = decoded
            .map((e) => WheelSegment.fromJson(e as Map<String, dynamic>))
            .toList();
        if (segments.length >= 2) {
          loadedSegments = segments;
        }
      } catch (_) {
        // Malformed data
      }
    }
    state = WheelState(name: rawName, segments: loadedSegments);
  }

  Future<void> saveSegments() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(state.segments.map((s) => s.toJson()).toList());
    await prefs.setString(_kSegmentsKey, encoded);
    await prefs.setString(_kWheelNameKey, state.name);
  }

  void loadPreset(String name, List<WheelSegment> segments) {
    state = WheelState(name: name, segments: segments);
    saveSegments();
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void addSegment() {
    if (state.segments.length >= 12) return;
    final index = state.segments.length;
    final color = paletteColor(index);
    final list = [...state.segments, WheelSegment(label: 'Option ${index + 1}', color: color)];
    state = state.copyWith(segments: list);
  }

  void removeSegment(int index) {
    if (state.segments.length <= 2) return;
    final list = [...state.segments];
    list.removeAt(index);
    state = state.copyWith(segments: list);
  }

  void updateLabel(int index, String label) {
    final list = [...state.segments];
    list[index] = list[index].copyWith(label: label);
    state = state.copyWith(segments: list);
  }

  void updateColor(int index, Color color) {
    final list = [...state.segments];
    list[index] = list[index].copyWith(color: color);
    state = state.copyWith(segments: list);
  }
}

final wheelProvider = StateNotifierProvider<WheelNotifier, WheelState>(
  (ref) => WheelNotifier(),
);
