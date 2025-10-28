import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Firebase Firestore

class RegisterContactScreen extends StatefulWidget {
  const RegisterContactScreen({super.key});

  @override
  State<RegisterContactScreen> createState() => _RegisterContactScreenState();
}

class _RegisterContactScreenState extends State<RegisterContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance

   _saveContact() async {
    debugPrint("Saving Contact...");
    if (_formKey.currentState!.validate()) {
      await _firestore.collection('contacts').add({
        'name': _nameController.text,
        'number': _numberController.text,
      });

      debugPrint("Contact Saved: ${_nameController.text}, ${_numberController.text}");
      _nameController.clear();
      _numberController.clear();
      Navigator.of(context).pop(true); // return true to refresh contacts
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Contacts"),
        backgroundColor: const Color(0xFF1E1B4B),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter a name" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter a number" : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  print("Save Contact Button Pressed");
                  _saveContact();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Save Contact",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
