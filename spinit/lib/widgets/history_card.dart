import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/history_entry.dart';

class HistoryCard extends StatelessWidget {
  final HistoryEntry entry;

  const HistoryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    Color parsedColor = Colors.white;
    try {
      parsedColor = Color(int.parse(entry.resultColor.replaceFirst('#', '0xFF')));
    } catch (_) {}

    final date = DateTime.tryParse(entry.timestamp) ?? DateTime.now();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          // Emoji or Initial Circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: parsedColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: parsedColor, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              _extractEmojiOrInitials(entry.resultLabel),
              style: TextStyle(
                fontSize: 20,
                color: parsedColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.resultLabel,
                  style: GoogleFonts.righteous(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  entry.wheelName,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Colors.white54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Relative time
          Text(
            _formatRelativeTime(date),
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    ).animate().slideX(begin: 0.2, end: 0, curve: Curves.easeOutCubic, duration: 400.ms).fadeIn();
  }

  String _extractEmojiOrInitials(String text) {
    if (text.isEmpty) return '?';
    // If it contains an emoji, try to return it
    final emojis = text.characters.where((char) => char.runes.any((r) => r >= 0x1F300)).toList();
    if (emojis.isNotEmpty) return emojis.last;
    return text.characters.first.toUpperCase();
  }

  String _formatRelativeTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? "min" : "mins"} ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? "hr" : "hrs"} ago';
    }
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    
    return DateFormat('MMM d').format(time);
  }
}
