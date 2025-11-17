// scaffold_with_nav.dart
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

    // inne ekrany niz ios
    if (bottomSafeAreaPadding == 0) {
      bottomSafeAreaPadding = 10;
    }

    return Scaffold(
      extendBody: true, // Kluczowe, by body szło pod pasek
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
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),

          // Zamiast BottomNavigationBar, budujemy własny
          child: ClipRRect(
            borderRadius: BorderRadius.circular(45.0),

            // ✅ KROK 1: Używamy Row, aby ułożyć elementy poziomo
            child: Row(
              // Rozkładamy elementy równomiernie
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // ✅ KROK 2: Budujemy każdy element ręcznie
                _buildNavItem(
                  icon: Icons.home,
                  label: 'Dom',
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
                  isSelected: navigationShell.currentIndex == 2,
                  onTap: () => _onTap(2),
                  selectedColor: Color.fromARGB(255, 114, 158, 216),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ KROK 3: Funkcja pomocnicza do budowania pojedynczej ikonki
  // (Umieść ją wewnątrz klasy ScaffoldWithNav, ale poza metodą build)
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color selectedColor,
  }) {
    // Kolory z Twojego zrzutu ekranu
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

    // InkWell daje efekt "plusku" przy kliknięciu
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30.0), // Dopasuj do kształtu
      // Padding kontroluje wysokość paska
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7.0),
        child: Column(
          // Ważne: aby kolumna była tak mała, jak to możliwe
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: itemColor, size: 28), // Większa ikona
            SizedBox(height: 3), // Mały odstęp
            Text(
              label,
              style: TextStyle(
                color: itemColor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
