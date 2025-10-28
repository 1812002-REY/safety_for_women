import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:telephony_fix/telephony.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../components/bottom_navigation.dart';
import 'register_contact_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Telephony telephony = Telephony.instance;
  int _selectedIndex = 1;

  Stream<QuerySnapshot<Map<String, dynamic>>> _contactsStream() {
    return _firestore.collection('contacts').snapshots();
  }

  Future<void> _deleteContact(String docId) async {
    await _firestore.collection('contacts').doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact deleted successfully')),
    );
  }

  void _showDeleteDialog(BuildContext context, String docId, String name) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Contact', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteContact(docId);
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }



  Future<void> _callNumber(String number) async {
    final Uri callUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot call $number')),
      );
          // throw Exception('Could not launch $callUri');
    }
  }

  Future<void> _sendLocationSMS(String number) async {
    try {
      PermissionStatus smsStatus = await Permission.sms.request();
      PermissionStatus locStatus = await Permission.locationWhenInUse.request();

      if (smsStatus.isGranted && locStatus.isGranted) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        final String message =
            'Emergency! My location: https://maps.google.com/?q=${position.latitude},${position.longitude}';

        bool? permissionGranted = await telephony.requestSmsPermissions;

        if (permissionGranted == true) {
          await telephony.sendSms(
            to: number,
            message: message,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Emergency SMS sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SMS or Location permission denied')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending SMS: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final padding = screenWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: Colors.purple[800],
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}), // manual refresh
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _contactsStream(), // automatic refresh
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6B46C1)),
            );
          }

          final contacts = snapshot.data?.docs ?? [];

          if (contacts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.contacts_outlined,
                      size: isTablet ? 120 : 80, color: const Color(0xFF9CA3AF)),
                  SizedBox(height: padding),
                  Text('No Emergency Contacts',
                      style: TextStyle(
                          fontSize: isTablet ? 24 : 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF374151))),
                  SizedBox(height: padding * 0.5),
                  Text('Add your first emergency contact\nusing the + button below',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          color: const Color(0xFF6B7280))),
                  SizedBox(height: padding),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterContactScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Contact'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(padding),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              final data = contact.data();
              return Padding(
                padding: EdgeInsets.only(bottom: padding * 0.5),
                child: Card(
                  color: const Color(0xFF2D2A5F).withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                  ),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: isTablet ? 12 : 8,
                      horizontal: isTablet ? 20 : 16,
                    ),
                    leading: Container(
                      width: isTablet ? 56 : 48,
                      height: isTablet ? 56 : 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                      ),
                      child: Center(
                        child: Text(
                          data['name'][0].toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6366F1),
                            fontSize: isTablet ? 18 : 16,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      data['name'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      data['number'],
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isTablet ? 16 : 14,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.phone,
                              color: const Color(0xFF10B981),
                              size: isTablet ? 28 : 24),
                          onPressed: () => _callNumber(data['number']),
                          tooltip: 'Call',
                        ),
                        IconButton(
                          icon: Icon(Icons.message,
                              color: Colors.orange, size: isTablet ? 28 : 24),
                          onPressed: () => _sendLocationSMS(data['number']),
                          tooltip: 'Send Location',
                        ),
                        IconButton(
                          icon: Icon(Icons.delete,
                              color: const Color(0xFFDC2626),
                              size: isTablet ? 28 : 24),
                          onPressed: () =>
                              _showDeleteDialog(context, contact.id, data['name']),
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterContactScreen()),
          );
        },
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        icon: Icon(Icons.add, size: isTablet ? 28 : 24),
        label: Text('Add Contact',
            style: TextStyle(
                fontSize: isTablet ? 16 : 14, fontWeight: FontWeight.bold)),
      ),
      // bottomNavigationBar: BottomNavigation(
      //   selectedIndex: _selectedIndex,
      //   onDestinationSelected: _onItemTapped,
      // ),
    );
  }
}
