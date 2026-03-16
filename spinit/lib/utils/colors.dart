import 'package:flutter/material.dart';

const List<Color> kWheelPalette = [
  Color(0xFFFF6B6B),
  Color(0xFFFF9F43),
  Color(0xFFFECA57),
  Color(0xFF48DBFB),
  Color(0xFF1DD1A1),
  Color(0xFFFF9FF3),
  Color(0xFF54A0FF),
  Color(0xFF5F27CD),
  Color(0xFFEE5A24),
  Color(0xFF009432),
  Color(0xFF0652DD),
  Color(0xFF833471),
];

Color paletteColor(int index) => kWheelPalette[index % kWheelPalette.length];
