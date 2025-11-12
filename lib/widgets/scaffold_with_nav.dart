// scaffold_with_nav.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNav extends StatelessWidget {
  const ScaffoldWithNav({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey('ScaffoldWithNav'));

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      // 'initialLocation: true' oznacza, że jeśli wrócimy do zakładki,
      // to zresetuje ona swoją historię nawigacji (opcjonalne)
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: navigationShell,
    
    bottomNavigationBar: Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      
      child: FractionallySizedBox(
        widthFactor: 0.8, 

        // Ten Container nadaje TŁO i KSZTAŁT
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFE5E5E5), 
            borderRadius: BorderRadius.circular(45.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),

          // ClipRRect WYMUSZA obcięcie rogów na dziecku
          child: ClipRRect(
            // Ważne: ten sam radius co w Container
            borderRadius: BorderRadius.circular(45.0), 
            
            child: BottomNavigationBar(
              // Ustaw tło paska na przezroczyste
              backgroundColor: Colors.transparent,
              elevation: 0, // Wyłącz domyślny cień paska
              
              currentIndex: navigationShell.currentIndex,
              onTap: _onTap, 
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Dom',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Szukaj',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}