import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/editor_screen.dart';
import 'screens/history_screen.dart';
import 'screens/presets_screen.dart';
import 'screens/spin_screen.dart';
import 'utils/haptics.dart';
import 'utils/sound_manager.dart';

void main() {
  runApp(
    const ProviderScope(
      child: SpinItApp(),
    ),
  );
}

class SpinItApp extends StatelessWidget {
  const SpinItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpinIt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        useMaterial3: true,
        textTheme: GoogleFonts.nunitoTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (_) => const MainLayout());
        }
        if (settings.name == '/editor') {
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const EditorScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
          );
        }
        return null;
      },
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    SpinScreen(),
    PresetsScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF2A2A2A), width: 1.0)),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF1A1A2E),
          currentIndex: _currentIndex,
          selectedItemColor: const Color(0xFFFF6B6B),
          unselectedItemColor: const Color(0xFF555555),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            soundManager.playButtonTap();
            Haptics.selection();
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.data_usage_outlined, size: 28),
              activeIcon: Icon(Icons.data_usage, size: 30),
              label: 'Spin',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined, size: 28),
              activeIcon: Icon(Icons.grid_view, size: 30),
              label: 'Presets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined, size: 28),
              activeIcon: Icon(Icons.history, size: 30),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}
