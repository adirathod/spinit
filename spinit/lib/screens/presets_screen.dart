import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/presets_data.dart';
import '../widgets/preset_card.dart';

class PresetsScreen extends StatelessWidget {
  const PresetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                '🎨 Wheel Presets',
                style: GoogleFonts.righteous(
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: presetPacks.length,
                itemBuilder: (context, index) {
                  return PresetCard(pack: presetPacks[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
