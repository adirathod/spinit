import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wheel_segment.dart';
import '../models/share_result.dart';
import '../services/api_service.dart';
import '../utils/haptics.dart';
import '../utils/sound_manager.dart';

class ShareBottomSheet extends StatefulWidget {
  final String wheelName;
  final List<WheelSegment> segments;

  const ShareBottomSheet({
    super.key,
    required this.wheelName,
    required this.segments,
  });

  @override
  State<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  bool _isLoading = false;
  ShareResult? _result;
  String? _error;

  Future<void> _shareWheel() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await apiService.shareWheel(widget.wheelName, widget.segments);
      setState(() {
        _result = result;
        _isLoading = false;
      });
      Haptics.heavy();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteWheel() async {
    if (_result == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Shared Wheel?'),
        content: const Text('This will remove the share code immediately. People with the code will no longer be able to load it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await apiService.deleteWheel(_result!.shareCode);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          if (_result == null) _buildInitialState() else _buildSharedState(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Column(
      children: [
        const Text(
          '📤 Share This Wheel',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),
        const Text(
          'Anyone with the code can load this exact wheel. Code expires in 30 days.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 32),
        if (_isLoading)
          const CircularProgressIndicator(color: Color(0xFFFF6B6B))
        else
          ElevatedButton(
            onPressed: _shareWheel,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Share & Get Code', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
        ],
      ],
    );
  }

  Widget _buildSharedState() {
    return Column(
      children: [
        const Text(
          '✅ Wheel Shared!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1DD1A1)),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Text(
            _result!.shareCode,
            style: GoogleFonts.righteous(fontSize: 40, color: Colors.white, letterSpacing: 4),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(Icons.copy, 'Copy Code', () {
              Clipboard.setData(ClipboardData(text: _result!.shareCode));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied!'), duration: Duration(seconds: 1)));
            }),
            const SizedBox(width: 16),
            _buildActionButton(Icons.link, 'Copy Link', () {
              Clipboard.setData(ClipboardData(text: 'spinitapp.com/join/${_result!.shareCode}'));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied!'), duration: Duration(seconds: 1)));
            }),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'Expires on ${_result!.expiresAt.day}/${_result!.expiresAt.month}/${_result!.expiresAt.year}',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        TextButton.icon(
          onPressed: _deleteWheel,
          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
          label: const Text('Delete Shared Wheel', style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.white10,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          soundManager.playButtonTap();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: Colors.white70),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
