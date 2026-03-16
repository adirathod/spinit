import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/wheel_provider.dart';
import '../utils/colors.dart';
import '../utils/sound_manager.dart';
import '../utils/haptics.dart';
import '../widgets/wheel_painter.dart';
import '../widgets/segment_tile.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final name = ref.read(wheelProvider).name;
    _nameController = TextEditingController(text: name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wheelProvider);
    final notifier = ref.read(wheelProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () {
            soundManager.playButtonTap();
            Haptics.selection();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Customize Wheel',
          style: GoogleFonts.righteous(color: Colors.white, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          // Live preview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            child: SizedBox(
              width: 140,
              height: 140,
              child: CustomPaint(
                painter: WheelPainter(segments: state.segments),
              ),
            ),
          ),

          // Wheel Name Editor
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(fontSize: 18, color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1A1A2E),
                hintText: 'Wheel Name (e.g. What to Eat?)',
                hintStyle: const TextStyle(color: Colors.white38),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: notifier.updateName,
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              '${state.segments.length} / 12 segments (Long press color to change)',
              style: GoogleFonts.nunito(color: Colors.white38, fontSize: 13),
            ),
          ),

          // Segment List
          Expanded(
            child: ListView.builder(
              itemCount: state.segments.length,
              itemBuilder: (context, index) {
                return SegmentTile(
                  key: ValueKey('segment_$index'),
                  segment: state.segments[index],
                  index: index,
                  onLabelChanged: (label) => notifier.updateLabel(index, label),
                  onColorChanged: (color) => notifier.updateColor(index, color),
                  onDelete: () {
                    if (state.segments.length <= 2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Minimum 2 segments required!'),
                          backgroundColor: Colors.red.shade700,
                        ),
                      );
                    } else {
                      notifier.removeSegment(index);
                    }
                  },
                );
              },
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            decoration: const BoxDecoration(
              color: Color(0xFF111111),
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      soundManager.playButtonTap();
                      Haptics.selection();
                      if (state.segments.length >= 12) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Maximum 12 segments allowed!'),
                            backgroundColor: Colors.orange.shade800,
                          ),
                        );
                      } else {
                        notifier.addSegment();
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: Text('Add Segment', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kWheelPalette[state.segments.length % kWheelPalette.length],
                      side: BorderSide(color: kWheelPalette[state.segments.length % kWheelPalette.length], width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF9F43)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFFF6B6B).withValues(alpha: 0.4), blurRadius: 12),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        soundManager.playButtonTap();
                        Haptics.selection();
                        await notifier.saveSegments();
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Text('Save & Spin', style: GoogleFonts.righteous(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
