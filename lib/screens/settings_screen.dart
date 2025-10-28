import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/bottom_navigation.dart';
import '../providers/notification_provider.dart';
import '../providers/theme_provider.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final String username;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.username,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  late bool _darkTheme;
  int _selectedIndex = 2; // Settings tab index

  @override
  void initState() {
    super.initState();
    _darkTheme = widget.isDarkMode;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (index == 1) {
        Navigator.pushReplacementNamed(context, '/contacts');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final notificationProvider = Provider.of<NotificationProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);


    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        title: const Text("Settings"),
        centerTitle: true,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 20),
          
                // Profile Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                  color: colorScheme.primary,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.onPrimary,
                      child: Icon(Icons.person, color: colorScheme.primary),
                    ),
                    title: Text(
                      widget.username,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "My Profile",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
          
                const SizedBox(height: 24),
          
                // Preferences Section
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 12,
                  color: theme.cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Notifications Switch
                        ListTile(
                          leading: Icon(
                            Icons.notifications,
                            color: colorScheme.secondary,
                          ),
                          title: Text(
                            "Enable Notifications",
                            style: theme.textTheme.bodyMedium,
                          ),
                          trailing: Switch(
                            value: notificationProvider.isNotificationEnabled,
                            onChanged: (value) {
                              debugPrint("Change notification to $value");
                              notificationProvider.toggleNotification();
                            },
                            activeColor: colorScheme.secondary,
                          ),
                        ),
          
                        const Divider(),
          
                        // Dark Mode Switch
                        ListTile(
                          leading: Icon(
                            Icons.dark_mode,
                            color: colorScheme.secondary,
                          ),
                          title: Text(
                            "Dark Theme",
                            style: theme.textTheme.bodyMedium,
                          ),
                          trailing: Switch(
                            value:  themeProvider.isDarkMode,
                            onChanged: (value) {
                              themeProvider.toggleTheme();
                            },
                            activeColor: colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          
                const SizedBox(height: 24),
          
                // Logout Section
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 12,
                  color: theme.cardColor,
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: Text("Logout", style: theme.textTheme.bodyMedium),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: colorScheme.secondary,
                    ),
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

      // bottomNavigationBar: BottomNavigation(
      //   selectedIndex: _selectedIndex,
      //   onDestinationSelected: _onItemTapped,
      // ),
    );
  }
}
