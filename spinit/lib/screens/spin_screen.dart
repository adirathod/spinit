import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../models/history_entry.dart';
import '../providers/history_provider.dart';
import '../providers/sound_provider.dart';
import '../providers/wheel_provider.dart';
import '../utils/haptics.dart';
import '../utils/sound_manager.dart';
import '../services/api_service.dart';
import '../utils/spin_calculator.dart';
import '../widgets/share_bottom_sheet.dart';
import '../widgets/result_sheet.dart';
import '../widgets/spin_button.dart';
import '../widgets/wheel_painter.dart';

class SpinScreen extends ConsumerStatefulWidget {
  const SpinScreen({super.key});

  @override
  ConsumerState<SpinScreen> createState() => _SpinScreenState();
}

class _SpinScreenState extends ConsumerState<SpinScreen>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  double _currentAngle = 0;
  double _totalRotation = 0;
  bool _isSpinning = false;
  final _random = Random();
  double _lastTickAngle = 0;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _startSpin() {
    if (_isSpinning) return;
    
    soundManager.playButtonTap();
    Haptics.selection();

    setState(() {
      _isSpinning = true;
      _lastTickAngle = _currentAngle;
    });

    final duration = Duration(milliseconds: 3500 + _random.nextInt(1500));
    final randomFinalAngle = _random.nextDouble() * 2 * pi;
    final totalRotation = (4 + _random.nextDouble() * 4) * 2 * pi + randomFinalAngle;

    _spinController.reset();
    _spinController.duration = duration;

    _spinAnimation = Tween<double>(begin: _currentAngle, end: _currentAngle + totalRotation)
        .animate(CurvedAnimation(
      parent: _spinController,
      curve: Curves.decelerate,
    ));

    final segmentCount = ref.read(wheelProvider).segments.length;
    final tickInterval = (2 * pi) / segmentCount;

    _spinAnimation.addListener(() {
      setState(() {
        _currentAngle = _spinAnimation.value;
        _totalRotation = _currentAngle;
      });

      // Play tick sound & haptic every time we cross a segment boundary
      if ((_currentAngle - _lastTickAngle) >= tickInterval) {
        _lastTickAngle = _currentAngle;
        soundManager.playTick();
        Haptics.light();
      }
    });

    _spinController.forward().whenComplete(() {
      setState(() {
        _isSpinning = false;
        _currentAngle = _currentAngle % (2 * pi);
      });
      _handleWin();
    });
  }

  void _handleWin() {
    final wheelState = ref.read(wheelProvider);
    final winner = getWinningSegment(_totalRotation, wheelState.segments);

    // Save to history
    final entry = HistoryEntry(
      id: const Uuid().v4(),
      wheelName: wheelState.name,
      resultLabel: winner.label,
      resultColor: '#${winner.color.r.toInt().toRadixString(16).padLeft(2, '0')}'
          '${winner.color.g.toInt().toRadixString(16).padLeft(2, '0')}'
          '${winner.color.b.toInt().toRadixString(16).padLeft(2, '0')}',
      timestamp: DateTime.now().toIso8601String(),
    );
    ref.read(historyProvider.notifier).addEntry(entry);

    // Log spin to backend if it's a shared wheel
    if (wheelState.shareCode != null) {
      apiService.logSpin(
        wheelState.shareCode!,
        winner.label,
        '#${winner.color.r.toInt().toRadixString(16).padLeft(2, '0')}'
            '${winner.color.g.toInt().toRadixString(16).padLeft(2, '0')}'
            '${winner.color.b.toInt().toRadixString(16).padLeft(2, '0')}',
      ).catchError((_) {}); // Silent fail for analytics
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ResultSheet(
        winner: winner,
        onSpinAgain: _startSpin, // the result sheet dismisses itself before calling this
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wheelState = ref.watch(wheelProvider);
    final isMuted = ref.watch(soundProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const SizedBox(width: 48), // balance mute button
                  Expanded(
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFF6B6B), Color(0xFFFF9F43), Color(0xFFFECA57)],
                      ).createShader(bounds),
                      child: Text(
                        'SpinIt',
                        style: GoogleFonts.righteous(
                          fontSize: 32,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: Colors.white70),
                    onPressed: () {
                      Haptics.selection();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => ShareBottomSheet(
                          wheelName: wheelState.name,
                          segments: wheelState.segments,
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white70),
                    onPressed: () {
                      Haptics.selection();
                      ref.read(soundProvider.notifier).toggleMute();
                    },
                  ),
                ],
              ),
            ),

            // Wheel name & badge
            const SizedBox(height: 16),
            Text(
              wheelState.name,
              style: GoogleFonts.nunito(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${wheelState.segments.length} options',
                style: GoogleFonts.nunito(fontSize: 12, color: Colors.white54),
              ),
            ),

            // Wheel area
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: AnimatedBuilder(
                          animation: _spinController,
                          builder: (context, child) => CustomPaint(
                            painter: WheelPainter(
                              segments: wheelState.segments,
                              rotationAngle: _currentAngle,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -6,
                        child: CustomPaint(
                          size: const Size(28, 36),
                          painter: _PointerPainter(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // SPIN button
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: SpinButton(
                onPressed: _startSpin,
                isSpinning: _isSpinning,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSpinning ? null : () {
          soundManager.playButtonTap();
          Haptics.selection();
          Navigator.of(context).pushNamed('/editor');
        },
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit),
        label: Text('Edit Wheel', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
        ),
      ),
    );
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()..moveTo(0, 0)..lineTo(size.width, 0)..lineTo(size.width / 2, size.height)..close(),
      Paint()..color = Colors.black54..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawPath(
      Path()..moveTo(0, 0)..lineTo(size.width, 0)..lineTo(size.width / 2, size.height)..close(),
      Paint()..color = Colors.white..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      Path()..moveTo(0, 0)..lineTo(size.width, 0)..lineTo(size.width / 2, size.height)..close(),
      Paint()..color = const Color(0xFFFF6B6B)..style = PaintingStyle.stroke..strokeWidth = 2,
    );
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
