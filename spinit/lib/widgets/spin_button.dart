import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpinButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isSpinning;

  const SpinButton({super.key, this.onPressed, required this.isSpinning});

  @override
  State<SpinButton> createState() => _SpinButtonState();
}

class _SpinButtonState extends State<SpinButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = widget.isSpinning ? 1.0 : _pulseAnimation.value;
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.isSpinning ? null : widget.onPressed,
        child: Container(
          width: 140,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: widget.isSpinning
                ? const LinearGradient(
                    colors: [Color(0xFF555555), Color(0xFF333333)],
                  )
                : const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF9F43)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            boxShadow: widget.isSpinning
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFFFF6B6B).withValues(alpha: 0.6),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              widget.isSpinning ? 'Spinning...' : 'SPIN',
              style: GoogleFonts.righteous(
                fontSize: 22,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
