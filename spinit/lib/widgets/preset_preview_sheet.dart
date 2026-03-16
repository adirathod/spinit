import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/preset_pack.dart';
import '../providers/wheel_provider.dart';
import '../utils/sound_manager.dart';
import '../utils/haptics.dart';
import 'wheel_painter.dart';

class PresetPreviewSheet extends ConsumerWidget {
  final PresetPack pack;

  const PresetPreviewSheet({super.key, required this.pack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            '${pack.icon} ${pack.name}',
            style: GoogleFonts.righteous(fontSize: 24, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Live Wheel Preview
          SizedBox(
            width: 160,
            height: 160,
            child: CustomPaint(
              painter: WheelPainter(segments: pack.segments),
            ),
          ),
          const SizedBox(height: 24),

          // Segments list
          Text(
            pack.segments.map((s) => s.label).join(' • '),
            style: GoogleFonts.nunito(fontSize: 14, color: Colors.white60),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 32),

          // Buttons
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                soundManager.playButtonTap();
                Haptics.selection();
                ref.read(wheelProvider.notifier).loadPreset(pack.name, pack.segments);
                Navigator.of(context).pop();
                // Assumes this was called from tab 1 (Presets), we need to switch tabs via the main frame,
                // but BottomNavigationBar selection handles that.
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Use This Wheel', style: GoogleFonts.righteous(fontSize: 18)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: TextButton(
              onPressed: () {
                soundManager.playButtonTap();
                Haptics.selection();
                ref.read(wheelProvider.notifier).loadPreset(pack.name, pack.segments);
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/editor');
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Customize First', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
