# SpinIt 🎡

A fun, local wheel spinner app built with Flutter — Phase 1.

## Features

- 🎨 Beautiful animated spinning wheel with 12-color vibrant palette
- 🎉 Confetti celebration on result
- ✏️ Real-time wheel editor with live preview
- 💾 Segments saved locally with SharedPreferences
- 📱 Works on Android & iOS — no internet needed

## Getting Started

### Prerequisites

- Flutter SDK (stable) — [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
- Android Studio or Xcode (for device/emulator)

### Run the App

```bash
# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Or run on specific platform
flutter run -d android
flutter run -d ios
```

### Build APK (Android)

```bash
flutter build apk --debug
```

## Project Structure

```
lib/
├── main.dart                  # App entry point, theme, routes
├── models/
│   └── wheel_segment.dart     # WheelSegment { label, color }
├── providers/
│   └── wheel_provider.dart    # Riverpod state + SharedPreferences
├── screens/
│   ├── spin_screen.dart       # Screen 1: Spin the wheel
│   └── editor_screen.dart     # Screen 2: Customize segments
├── utils/
│   ├── colors.dart            # 12-color vibrant palette
│   └── spin_calculator.dart   # Winning segment math
└── widgets/
    ├── wheel_painter.dart     # CustomPainter for the wheel
    ├── spin_button.dart       # Glowing SPIN button
    ├── result_sheet.dart      # Result modal + confetti
    └── segment_tile.dart      # Editor list item
```

## Packages Used

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `shared_preferences` | Local segment storage |
| `confetti` | Celebration animation |
| `google_fonts` | Nunito + Righteous fonts |

---
Phase 1 — Wheel Spinner UI only. No backend, no auth, no networking.
