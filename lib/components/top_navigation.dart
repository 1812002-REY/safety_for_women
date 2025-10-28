import 'package:flutter/material.dart';

class TopNavigation extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final String? subtitle;
  
  const TopNavigation({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: isTablet ? 24 : 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFF6B46C1),
      foregroundColor: Colors.white,
      elevation: 4,
      centerTitle: true,
      automaticallyImplyLeading: showBackButton,
      actions: actions,
      toolbarHeight: isTablet ? 70 : 56,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56);
}