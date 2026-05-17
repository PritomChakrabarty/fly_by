import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';
import 'home/home_screen.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    const screens = [
      HomeScreen(),
      Scaffold(body: Center(child: Text('Flights'))),
      Scaffold(body: Center(child: Text('Map'))),
      Scaffold(body: Center(child: Text('Profile'))),
    ];

    return Scaffold(
      body: screens[currentIndex],
      // Replace the bottomNavigationBar in MainShell with this:
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavIcon(Icons.home_rounded, 0, currentIndex, ref),
                _buildNavIcon(Icons.flight_rounded, 1, currentIndex, ref),
                _buildNavIcon(Icons.map_outlined, 2, currentIndex, ref),
                _buildNavIcon(
                    Icons.person_outline_rounded, 3, currentIndex, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, int currentIndex, WidgetRef ref) {
  final isActive = index == currentIndex;
  
  Widget iconWidget = Icon(
    icon,
    size: 26,
    color: isActive ? const Color(0xFF2563EB) : const Color(0xFF9CA3AF),
  );
  
  if (index == 1) {
    iconWidget = Transform.rotate(
      angle: 1.55,
      child: iconWidget,
    );
  }
  
  return GestureDetector(
    onTap: () => ref.read(bottomNavIndexProvider.notifier).state = index,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: iconWidget,
    ),
  );
}
}

class _BottomNavBar extends ConsumerWidget {
  final int currentIndex;
  const _BottomNavBar({required this.currentIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                  icon: Icons.home_rounded,
                  index: 0,
                  currentIndex: currentIndex),
              _NavItem(
                  icon: Icons.flight_rounded,
                  index: 1,
                  currentIndex: currentIndex),
              _NavItem(
                  icon: Icons.map_outlined,
                  index: 2,
                  currentIndex: currentIndex),
              _NavItem(
                  icon: Icons.person_outline,
                  index: 3,
                  currentIndex: currentIndex),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends ConsumerWidget {
  final IconData icon;
  final int index;
  final int currentIndex;

  const _NavItem({
    required this.icon,
    required this.index,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => ref.read(bottomNavIndexProvider.notifier).state = index,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF2563EB) : const Color(0xFF9CA3AF),
            size: 26,
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
