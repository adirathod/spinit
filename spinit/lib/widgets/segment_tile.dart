import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wheel_segment.dart';
import '../utils/colors.dart';
import '../utils/sound_manager.dart';
import '../utils/haptics.dart';

class SegmentTile extends StatefulWidget {
  final WheelSegment segment;
  final int index;
  final ValueChanged<String> onLabelChanged;
  final ValueChanged<Color>? onColorChanged;
  final VoidCallback onDelete;

  const SegmentTile({
    super.key,
    required this.segment,
    required this.index,
    required this.onLabelChanged,
    this.onColorChanged,
    required this.onDelete,
  });

  @override
  State<SegmentTile> createState() => _SegmentTileState();
}

class _SegmentTileState extends State<SegmentTile> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.segment.label);
  }

  @override
  void didUpdateWidget(SegmentTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.segment.label != widget.segment.label &&
        _controller.text != widget.segment.label) {
      _controller.text = widget.segment.label;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showColorPicker() {
    Haptics.medium();
    soundManager.playButtonTap();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pick a Color',
                style: GoogleFonts.righteous(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: kWheelPalette.map((color) {
                  final isSelected = widget.segment.color == color;
                  return GestureDetector(
                    onTap: () {
                      Haptics.selection();
                      soundManager.playButtonTap();
                      widget.onColorChanged?.call(color);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                        ],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _showColorPicker,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.segment.color.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Color swatch
            GestureDetector(
              onTap: _showColorPicker,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: widget.segment.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.segment.color.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Editable label
            Expanded(
              child: TextField(
                controller: _controller,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                onChanged: widget.onLabelChanged,
              ),
            ),

            // Delete icon
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () {
                soundManager.playButtonTap();
                Haptics.medium();
                widget.onDelete();
              },
              tooltip: 'Remove segment',
            ),
          ],
        ),
      ),
    );
  }
}
