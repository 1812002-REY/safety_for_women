import 'package:flutter/material.dart';
import 'package:safety_for_woman/components/top_navigation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:telephony_fix/telephony.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import '../components/bottom_navigation.dart';
import 'contacts_screen.dart';
import 'settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';


class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLiked = false;
  String _statusMessage = 'Ready';
   bool _isDarkMode = false;

  // Emergency functionality
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Telephony telephony = Telephony.instance;
  
  // Shake detection
  static const double shakeThreshold = 15.0;
  int lastShakeTime = 0;

  @override
  void initState() {
    super.initState();
    _initializeShakeDetection();
    _requestPermissions();
  }

  void _initializeShakeDetection() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      double gX = event.x / 9.81;
      double gY = event.y / 9.81;
      double gZ = event.z / 9.81;
      double gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

      int now = DateTime.now().millisecondsSinceEpoch;
      if (gForce > shakeThreshold && now - lastShakeTime > 2000) {
        lastShakeTime = now;
        _showEmergencyDialog();
      }
    });
  }

  Future<void> _requestPermissions() async {
    await Permission.sms.request();
    await Permission.phone.request();
    await Permission.locationWhenInUse.request();
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('EMERGENCY DETECTED!'),
        content: const Text('Shake detected! Send emergency alerts to all contacts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _triggerEmergency();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Send Alert'),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerEmergency() async {
    setState(() {
      _statusMessage = 'Sending emergency alerts...';
    });

    try {
      // Get all contacts from Firestore
      final snapshot = await _firestore.collection('contacts').get();
      
      if (snapshot.docs.isEmpty) {
        setState(() {
          _statusMessage = 'No emergency contacts found!';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add emergency contacts first!'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Get current location
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (e) {
        print('Could not get location: $e');
      }

      // Prepare emergency message
      String emergencyMessage = "🚨 EMERGENCY ALERT! 🚨\n";
      emergencyMessage += "${widget.username} needs immediate help!\n";
      emergencyMessage += "This is an automated emergency message.\n";
      
      if (position != null) {
        emergencyMessage += "Location: https://maps.google.com/?q=${position.latitude},${position.longitude}\n";
      }
      
      emergencyMessage += "Please contact them immediately or call emergency services.";

      // Send SMS to all contacts
      bool? permissionGranted = await telephony.requestSmsPermissions;
      
      if (permissionGranted == true) {
        int sentCount = 0;
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final phoneNumber = data['number'] as String;
          
          try {
            await telephony.sendSms(
              to: phoneNumber,
              message: emergencyMessage,
            );
            sentCount++;
          } catch (e) {
            print('Error sending SMS to $phoneNumber: $e');
          }
        }

        setState(() {
          _statusMessage = 'Emergency alerts sent to $sentCount contacts';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Emergency alerts sent to $sentCount contacts!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _statusMessage = 'SMS permission denied';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SMS permission required for emergency alerts'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error sending alerts';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    // Reset status after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _statusMessage = 'Ready';
        });
      }
    });
  }

  void _toggleLike() {
    setState(() => _isLiked = !_isLiked);
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _buildHomeTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = (constraints.maxHeight * .55);
        final isTablet = screenWidth > 600;
        final padding = screenWidth * 0.04;

        final theme = Theme.of(context);
        final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;
        final titleColor = theme.textTheme.titleLarge?.color ?? Colors.black;
        final subtitleColor = theme.textTheme.bodySmall?.color ?? Colors.grey;
        final iconColor = theme.iconTheme.color ?? theme.colorScheme.primary;
        final cardColor = theme.cardColor;
        final primaryColor = theme.colorScheme.primary;
        final displayName = widget.username.split('@')[0];

        return Column(
          children: [
            TopNavigation(title:"Home"),
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: (MediaQuery.of(context).size.height * 0.9) - kToolbarHeight - kBottomNavigationBarHeight,
                  minHeight: screenHeight*.2
                ),
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Welcome Card - Fixed height
                      Card(
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                        ),
                        elevation: 6,
                        child: Container(
                          padding: EdgeInsets.all(isTablet ? 24 : 16),
                          height: isTablet ? 120 : 100,
                          child: Row(
                            children: [
                              Icon(Icons.shield,
                                  color: primaryColor, size: isTablet ? 50 : 40),
                              SizedBox(width: isTablet ? 20 : 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Hello, $displayName',
                                        style: theme.textTheme.titleLarge!.copyWith(
                                          fontSize: isTablet ? 24 : 20,
                                          color: titleColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Stay safe and protected',
                                      style: theme.textTheme.bodyMedium!.copyWith(
                                        fontSize: isTablet ? 16 : 14,
                                        color: subtitleColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: padding),
                      
                      // Status Message - Flexible height
                      Container(
                        padding: EdgeInsets.all(isTablet ? 16 : 12),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                        ),
                        child: Text(
                          _statusMessage,
                          style: theme.textTheme.bodyMedium!.copyWith(
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.w500,
                            color: primaryColor,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: padding * 1.5),
            
                      // Emergency Button - Fixed height with flexible content
                      SizedBox(
                        height: isTablet ? 140 : 120,
                        child: ElevatedButton(
                          onPressed: _triggerEmergency,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.warning, 
                                   size: isTablet ? 50 : 40, 
                                   color: Colors.white),
                              SizedBox(height: isTablet ? 12 : 8),
                              Text(
                                'START EMERGENCY',
                                style: TextStyle(
                                  fontSize: isTablet ? 20 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tap or shake device',
                                style: TextStyle(
                                  fontSize: isTablet ? 14 : 12,
                                  color: Colors.white70,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: padding * 1.5),
            
                      // Quick Actions
                      Text(
                        'Quick Actions',
                        style: theme.textTheme.titleLarge!.copyWith(
                          fontSize: isTablet ? 24 : 20,
                          color: titleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: padding * 0.7),
                      _buildActionCards(isTablet, padding, theme),
                      SizedBox(height: padding * 1.5),
            
                      // Recent Contacts Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Emergency Contacts',
                              style: theme.textTheme.titleLarge!.copyWith(
                                fontSize: isTablet ? 24 : 20,
                                color: titleColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () => _onItemTapped(1),
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      SizedBox(height: padding * 0.7),
                      
                      // Contacts Preview - Fixed height
                      _buildContactsPreview(),
                      
                      // Bottom padding for safe area
                      // SizedBox(height: padding),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionCards(bool isTablet, double padding, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            title: 'Call Emergency',
            subtitle: 'Quick dial',
            icon: Icons.phone,
            color: Colors.green,
            onTap: () => _callEmergencyContact(),
            isTablet: isTablet,
            theme: theme,
          ),
        ),
        SizedBox(width: padding),
        Expanded(
          child: _buildActionCard(
            title: 'Send Location',
            subtitle: 'Share GPS',
            icon: Icons.location_on,
            color: Colors.blue,
            onTap: () => _sendLocationToAll(),
            isTablet: isTablet,
            theme: theme,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isTablet,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        ),
        elevation: 4,
        child: Container(
          height: isTablet ? 110 : 90,
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: isTablet ? 32 : 28),
              SizedBox(height: isTablet ? 8 : 6),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isTablet ? 14 : 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactsPreview() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('contacts').limit(3).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Card(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.contacts_outlined, size: 30, color: Colors.grey),
                  const SizedBox(height: 8),
                  const Text(
                    'No contacts added',
                    style: TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  TextButton(
                    onPressed: () => _onItemTapped(1),
                    child: const Text(
                      'Add Contact',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final contact = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return Container(
              width: 120,
              margin: const EdgeInsets.only(right: 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: Text(
                          (contact['name']?.isNotEmpty == true) 
                              ? contact['name'][0].toUpperCase()
                              : '?',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          contact['name'] ?? 'Unknown',
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          contact['number'] ?? '',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _callEmergencyContact() async {
    final snapshot = await _firestore.collection('contacts').limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      final contact = snapshot.docs.first.data();
      final phoneNumber = contact['number'];
      final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
      
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No emergency contacts available')),
      );
    }
  }

  Future<void> _sendLocationToAll() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      final snapshot = await _firestore.collection('contacts').get();
      
      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No emergency contacts found')),
        );
        return;
      }

      String locationMessage = "My current location: https://maps.google.com/?q=${position.latitude},${position.longitude}";
      
      bool? permissionGranted = await telephony.requestSmsPermissions;
      
      if (permissionGranted == true) {
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final phoneNumber = data['number'];
          
          try {
            await telephony.sendSms(
              to: phoneNumber,
              message: locationMessage,
            );
          } catch (e) {
            print('Error sending location to $phoneNumber: $e');
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location sent to ${snapshot.docs.length} contacts'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Home username is ${widget.username}");
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.primary,
      //   elevation: 0,
      //   title: const Text("Home"),
        
      //   centerTitle: true,
      //   foregroundColor: Theme.of(context).colorScheme.onPrimary,
      // ),
     
      
      body: IndexedStack(
            index: _selectedIndex,
            children: [
              _buildHomeTab(),
              const ContactsScreen(),
            SettingsScreen(
            isDarkMode: _isDarkMode,
            onThemeChanged: (value) {
              setState(() => _isDarkMode = value);
            },
            username: widget.username,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
      ),
    );
  }
}  