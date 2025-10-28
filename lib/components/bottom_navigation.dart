import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: Colors.white, // Always visible
        indicatorColor: const Color(0xFF6B46C1).withOpacity(0.3),
        labelTextStyle: MaterialStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: isTablet ? 16 : 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        iconTheme: MaterialStateProperty.resolveWith(
          (states) {
            if (states.contains(MaterialState.selected)) {
              // Glow effect using shadow
              return IconThemeData(
                color: const Color(0xFF6B46C1),
                size: isTablet ? 28 : 24,
              );
            }
            return IconThemeData(
              color: Colors.grey[600],
              size: isTablet ? 28 : 24,
            );
          },
        ),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        height: isTablet ? 80 : 65,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.contacts),
            selectedIcon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
