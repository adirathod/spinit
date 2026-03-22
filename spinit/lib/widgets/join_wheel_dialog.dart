import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/shared_wheel_summary.dart';
import '../services/api_service.dart';
import '../utils/haptics.dart';
import '../utils/sound_manager.dart';

class JoinWheelDialog extends StatefulWidget {
  const JoinWheelDialog({super.key});

  @override
  State<JoinWheelDialog> createState() => _JoinWheelDialogState();
}

class _JoinWheelDialogState extends State<JoinWheelDialog> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _loadWheel() async {
    final code = _controller.text.trim().toUpperCase();
    if (code.length != 6) {
      setState(() => _error = 'Enter a 6-character code');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final wheel = await apiService.fetchWheel(code);
      if (mounted) {
        Haptics.heavy();
        Navigator.pop(context, wheel);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF111827),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🔗 Load a Shared Wheel',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLength: 6,
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              style: GoogleFonts.righteous(fontSize: 24, letterSpacing: 4, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'X7K2PQ',
                hintStyle: const TextStyle(color: Colors.white24),
                counterText: '',
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (val) {
                if (val.length == 6) {
                  _loadWheel();
                }
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _loadWheel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Load Wheel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
