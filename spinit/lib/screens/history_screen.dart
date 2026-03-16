import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/history_provider.dart';
import '../widgets/history_card.dart';
import '../utils/sound_manager.dart';
import '../utils/haptics.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '🕓 Spin History',
          style: GoogleFonts.righteous(color: Colors.white, fontSize: 24),
        ),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white70),
              onPressed: () {
                soundManager.playButtonTap();
                Haptics.medium();
                _showClearDialog(context, ref);
              },
            ),
        ],
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 80, color: Colors.white12),
                  const SizedBox(height: 16),
                  Text(
                    'No spins yet!',
                    style: GoogleFonts.nunito(
                        fontSize: 18, color: Colors.white54),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                return HistoryCard(entry: history[index]);
              },
            ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Clear History?', style: GoogleFonts.righteous(color: Colors.white)),
        content: Text('Are you sure you want to delete all spin history?', 
          style: GoogleFonts.nunito(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              soundManager.playButtonTap();
              Navigator.pop(context);
            },
            child: Text('Cancel', style: GoogleFonts.nunito(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              soundManager.playButtonTap();
              Haptics.heavy();
              ref.read(historyProvider.notifier).clearHistory();
              Navigator.pop(context);
            },
            child: Text('Clear', style: GoogleFonts.nunito(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
