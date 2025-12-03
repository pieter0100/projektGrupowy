import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNav extends StatelessWidget {
  const ScaffoldWithNav({required this.navigationShell, Key? key})
    : super(key: key ?? const ValueKey('ScaffoldWithNav'));

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    double bottomSafeAreaPadding = MediaQuery.of(context).padding.bottom;

    // devices that are not IOS
    if (bottomSafeAreaPadding == 0) {
      bottomSafeAreaPadding = 10;
    }

    return Scaffold(
      extendBody: true,
      body: navigationShell,

      bottomNavigationBar: FractionallySizedBox(
        widthFactor: 0.8,
        child: Container(
          margin: EdgeInsets.only(bottom: bottomSafeAreaPadding),
          decoration: BoxDecoration(
            color: Color(0xFFE5E5E5),
            borderRadius: BorderRadius.circular(45.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),

          child: ClipRRect(
            borderRadius: BorderRadius.circular(45.0),

            child: Row(
              // spaces between elements are even
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  label: 'Home',
                  isSelected: navigationShell.currentIndex == 0,
                  onTap: () => _onTap(0),
                  selectedColor: Color(0xFF41AC78),
                ),
                _buildNavItem(
                  icon: Icons.ads_click,
                  label: 'Leaderboard',
                  isSelected: navigationShell.currentIndex == 1,
                  onTap: () => _onTap(1),
                  selectedColor: Color(0xFFEB9F4A),
                ),
                _buildNavItem(
                  icon: Icons.people,
                  label: 'Profile',
                  isSelected: navigationShell.currentIndex == 2,
                  onTap: () => _onTap(2),
                  selectedColor: Color(0xFFAB70DF),
                ),
                _buildNavItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  isSelected: navigationShell.currentIndex == 3,
                  onTap: () => _onTap(3),
                  selectedColor: Color(0xFF729ED8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // function that builds single icon in navbar
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color selectedColor,
  }) {
    final Color unselectedColor = Colors.grey.shade600;
    final Color itemColor = isSelected ? selectedColor : unselectedColor;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: itemColor),
          Text(label, style: TextStyle(color: itemColor)),
        ],
      ),
    );
  }
}
