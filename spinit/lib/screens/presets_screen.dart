import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/presets_data.dart';
import '../widgets/preset_card.dart';
import '../widgets/join_wheel_dialog.dart';
import '../widgets/shared_wheel_card.dart';
import '../models/shared_wheel_summary.dart';
import '../services/api_service.dart';
import '../providers/wheel_provider.dart';
import '../providers/tab_provider.dart';
import '../utils/haptics.dart';
import '../utils/sound_manager.dart';

class PresetsScreen extends ConsumerStatefulWidget {
  const PresetsScreen({super.key});

  @override
  ConsumerState<PresetsScreen> createState() => _PresetsScreenState();
}

class _PresetsScreenState extends ConsumerState<PresetsScreen> {
  List<SharedWheelSummary>? _mySharedWheels;
  bool _isLoadingShared = false;

  @override
  void initState() {
    super.initState();
    _fetchMyWheels();
  }

  Future<void> _fetchMyWheels() async {
    setState(() => _isLoadingShared = true);
    try {
      final wheels = await apiService.getMySharedWheels();
      if (mounted) {
        setState(() {
          _mySharedWheels = wheels;
          _isLoadingShared = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingShared = false);
      }
    }
  }

  void _loadSharedToSpin(SharedWheelSummary wheel) {
    ref.read(wheelProvider.notifier).loadSharedWheel(wheel.name, wheel.segments, wheel.shareCode);
    ref.read(tabProvider.notifier).state = 0; // Switch to Spin tab
  }

  Future<void> _deleteWheel(String code) async {
    try {
      await apiService.deleteWheel(code);
      _fetchMyWheels();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchMyWheels,
          color: const Color(0xFFFF6B6B),
          backgroundColor: const Color(0xFF1A1A2E),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎨 Wheel Presets',
                        style: GoogleFonts.righteous(fontSize: 28, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      _buildJoinButton(),
                      const SizedBox(height: 24),
                      if (_mySharedWheels != null && _mySharedWheels!.isNotEmpty) ...[
                        _buildMySharedList(),
                        const SizedBox(height: 24),
                      ] else if (_isLoadingShared) ...[
                        _buildShimmerList(),
                        const SizedBox(height: 24),
                      ],
                      Text(
                        'Ready-to-Spin Packs',
                        style: GoogleFonts.nunito(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => PresetCard(pack: presetPacks[index]),
                    childCount: presetPacks.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoinButton() {
    return InkWell(
      onTap: () async {
        soundManager.playButtonTap();
        Haptics.selection();
        final SharedWheelSummary? wheel = await showDialog<SharedWheelSummary>(
          context: context,
          builder: (context) => const JoinWheelDialog(),
        );
        if (wheel != null) {
          _loadSharedToSpin(wheel);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFF6B6B).withValues(alpha: 0.5), width: 1.5),
        ),
        child: const Column(
          children: [
            Icon(Icons.link, color: Color(0xFFFF6B6B), size: 32),
            SizedBox(height: 8),
            Text(
              'Load a Shared Wheel',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              'Enter a 6-letter code',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMySharedList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Shared Wheels',
          style: GoogleFonts.nunito(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _mySharedWheels!.length,
            itemBuilder: (context, index) {
              final wheel = _mySharedWheels![index];
              return SharedWheelCard(
                wheel: wheel,
                onTap: () => _loadSharedToSpin(wheel),
                onDelete: () => _deleteWheel(wheel.shareCode),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 150, height: 20, color: Colors.white10),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) => Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }
}
