import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/preset_pack.dart';
import '../utils/sound_manager.dart';
import '../utils/haptics.dart';
import 'preset_preview_sheet.dart';

class PresetCard extends StatelessWidget {
  final PresetPack pack;

  const PresetCard({super.key, required this.pack});

  @override
  Widget build(BuildContext context) {
    // Determine gradient based on the first two colors of the pack (or fallback)
    final Color c1 = pack.segments.isNotEmpty ? pack.segments[0].color : Colors.blueGrey;
    final Color c2 = pack.segments.length > 1 ? pack.segments[1].color : Colors.grey;

    return GestureDetector(
      onTap: () {
        soundManager.playButtonTap();
        Haptics.selection();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => PresetPreviewSheet(pack: pack),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              c1.withValues(alpha: 0.15),
              c2.withValues(alpha: 0.05),
            ],
          ),
          border: Border.all(color: c1.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              pack.icon,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                pack.name,
                style: GoogleFonts.righteous(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
