import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wheel_segment.dart';
import '../utils/sound_manager.dart';
import '../utils/haptics.dart';

class ResultSheet extends StatefulWidget {
  final WheelSegment winner;
  final VoidCallback onSpinAgain;

  const ResultSheet({super.key, required this.winner, required this.onSpinAgain});

  @override
  State<ResultSheet> createState() => _ResultSheetState();
}

class _ResultSheetState extends State<ResultSheet> {
  late ConfettiController _confetti;
  bool _showSavedMsg = true;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _confetti.play();
    
    // Play sound and haptics
    soundManager.playResult();
    Haptics.heavy();

    // Auto-hide the "Added to History" message after 1.5s
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showSavedMsg = false);
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  String _extractEmoji(String text) {
    if (text.isEmpty) return '';
    final emojis = text.characters.where((char) => char.runes.any((r) => r >= 0x1F300)).toList();
    if (emojis.isNotEmpty) return emojis.last;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final emoji = _extractEmoji(widget.winner.label);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Bottom sheet content
        Container(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A2E),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '🎉 We have a winner!',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              
              if (emoji.isNotEmpty)
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 64),
                ),
              if (emoji.isNotEmpty) const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: widget.winner.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.winner.color.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: Text(
                  widget.winner.label,
                  style: GoogleFonts.righteous(
                    fontSize: 32,
                    color: widget.winner.color,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Transient Added to History text
              AnimatedOpacity(
                opacity: _showSavedMsg ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Add to History ✓',
                    style: GoogleFonts.nunito(color: Colors.white54, fontSize: 13),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    soundManager.playButtonTap();
                    Haptics.selection();
                    Navigator.of(context).pop();
                    Future.delayed(const Duration(milliseconds: 300), widget.onSpinAgain);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.winner.color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Spin Again',
                    style: GoogleFonts.righteous(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Confetti widget
        Positioned(
          top: -20,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 40,
            gravity: 0.3,
            emissionFrequency: 0.05,
            colors: const [
              Color(0xFFFF6B6B),
              Color(0xFFFF9F43),
              Color(0xFFFECA57),
              Color(0xFF48DBFB),
              Color(0xFF1DD1A1),
              Color(0xFFFF9FF3),
            ],
          ),
        ),
      ],
    );
  }
}
