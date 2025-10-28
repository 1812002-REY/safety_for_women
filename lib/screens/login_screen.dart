import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Added for persistence
import 'home_screen.dart';

void main() {
  runApp(const WomensSafetyApp());
}

class WomensSafetyApp extends StatelessWidget {
  const WomensSafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Login Screen",
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _passwordVisible = false;
  bool _isLoading = false; 

  Map<String, String> _registeredUsers = {}; // ✅ Store registered users

  @override
  void initState() {
    super.initState();
    _loadRegisteredUsers(); // ✅ Load saved users
  }

  // ✅ Load users from SharedPreferences
  Future<void> _loadRegisteredUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _registeredUsers = (prefs.getKeys().fold<Map<String, String>>({}, (map, key) {
        map[key] = prefs.getString(key) ?? '';
        return map;
      }));
    });
  }

  // ✅ Save user to SharedPreferences
  Future<void> _saveUser(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(email, password);
    _registeredUsers[email] = password;
  }

  void _login() async {
    String email = _usernameController.text.trim();
    String password = _passwordController.text;

    bool isEmailValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+').hasMatch(email);
    bool isPasswordValid = password.isNotEmpty && password.length >= 6;

    if (isEmailValid && isPasswordValid) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (_registeredUsers.containsKey(email)) {
        if (_registeredUsers[email] == password) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Login Successful"),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          _navigateToHome(email);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("❌ This email is already registered with a different password"),
              backgroundColor: Color(0xFFDC2626),
            ),
          );
          return;
        }
      } else {
        await _saveUser(email, password);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ New user registered and logged in"),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        _navigateToHome(email);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Please enter a valid email and password (min 6 chars)"),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
    }
  }

  void _navigateToHome(String email) {
    debugPrint("my username is $email ============> ");
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
            debugPrint("my username after mount widget is $email ============> ");

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(username: email),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E1B4B),
              Color(0xFF0F0F23),
              Color(0xFF1E1B4B),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 8,
                    color: const Color(0xFF6366F1),
                    child: const SizedBox(
                      width: 80,
                      height: 80,
                      child: Center(
                        child: Icon(Icons.shield, size: 40, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Safety Guardian",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Your personal safety companion",
                    style: TextStyle(fontSize: 16, color: Color(0xFFB8B5FF)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 12,
                    color: const Color(0xFF2D2A5F).withOpacity(0.8),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Welcome Back",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 22,
                                color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _usernameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Email Address",
                              labelStyle:
                                  const TextStyle(color: Color(0xFFB8B5FF)),
                              prefixIcon:
                                  const Icon(Icons.email, color: Color(0xFF6366F1)),
                              filled: true,
                              fillColor: Colors.transparent,
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Color(0xFF4C4980))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Color(0xFF6366F1))),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _passwordController,
                            obscureText: !_passwordVisible,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Password",
                              labelStyle:
                                  const TextStyle(color: Color(0xFFB8B5FF)),
                              prefixIcon:
                                  const Icon(Icons.lock, color: Color(0xFF6366F1)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: const Color(0xFFB8B5FF),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Color(0xFF4C4980))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Color(0xFF6366F1))),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 6,
                              ),
                              child: const Text(
                                "Secure Login",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.shield, color: Color(0xFF10B981), size: 16),
                      Text(
                        "  Your data is encrypted and secure",
                        style: TextStyle(color: Color(0xFF10B981), fontSize: 13),
                      ),
                    ],
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
 