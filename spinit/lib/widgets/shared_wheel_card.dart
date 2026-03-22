import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/shared_wheel_summary.dart';

class SharedWheelCard extends StatelessWidget {
  final SharedWheelSummary wheel;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const SharedWheelCard({
    super.key,
    required this.wheel,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final daysRemaining = wheel.expiresAt.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysRemaining < 5;

    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: const Color(0xFF111827),
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.play_arrow, color: Colors.white70),
                title: const Text('Load Wheel'),
                onTap: () {
                  Navigator.pop(context);
                  onTap();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text('Delete Shared Wheel', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wheel.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  wheel.shareCode,
                  style: GoogleFonts.righteous(color: Colors.white54, fontSize: 12, letterSpacing: 1),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '🔄 ${wheel.spinCount} spins',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isExpiringSoon ? Colors.redAccent.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Expires in $daysRemaining days',
                style: TextStyle(
                  color: isExpiringSoon ? Colors.redAccent : Colors.white54,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
