import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/notification_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings are initialized
  Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
      ],
      child: const WomensSafetyApp(),
    ),
  );
}

class WomensSafetyApp extends StatelessWidget {
  const WomensSafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'women safety ',
      themeMode: themeProvider.currentTheme,
      darkTheme: ThemeData.dark(),
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF6B46C1),
          secondary: const Color(0xFF10B981),
          surface: Colors.white,
          background: const Color(0xFFF9FAFB),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
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

  void _login() async {
    String email = _usernameController.text.trim();
    String password = _passwordController.text;

    // Basic email and password validation
    bool isEmailValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+').hasMatch(email);
    bool isPasswordValid = password.isNotEmpty && password.length >= 6;

    if (isEmailValid && isPasswordValid) {
      setState(() => _isLoading = true);

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Login Successful"),
          backgroundColor: Color(0xFF10B981),
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          // Navigator.of(context).pushReplacementNamed('/home');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomeScreen(username: email),
            ),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "❌ Please enter a valid email and password (min 6 chars)",
          ),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final padding = screenWidth * 0.08;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E1B4B), Color(0xFF0F0F23), Color(0xFF1E1B4B)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 500 : double.infinity,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Shield Icon Card
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            isTablet ? 28 : 20,
                          ),
                        ),
                        elevation: 8,
                        color: const Color(0xFF6366F1),
                        child: Container(
                          width: isTablet ? 100 : 80,
                          height: isTablet ? 100 : 80,
                          child: Center(
                            child: Icon(
                              Icons.shield,
                              size: isTablet ? 50 : 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: isTablet ? 32 : 24),

                      // Title
                      Text(
                        "Safety Guardian",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 36 : 28,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: isTablet ? 8 : 4),

                      Text(
                        "Your personal safety companion",
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 16,
                          color: const Color(0xFFB8B5FF),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: isTablet ? 64 : 48),

                      // Login Form Card
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            isTablet ? 28 : 20,
                          ),
                        ),
                        elevation: 12,
                        color: const Color(0xFF2D2A5F).withOpacity(0.8),
                        child: Padding(
                          padding: EdgeInsets.all(isTablet ? 32 : 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "Welcome Back",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: isTablet ? 28 : 22,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: isTablet ? 32 : 20),

                              // Email Field
                              TextField(
                                controller: _usernameController,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 18 : 16,
                                ),
                                decoration: InputDecoration(
                                  labelText: "Email Address",
                                  labelStyle: TextStyle(
                                    color: const Color(0xFFB8B5FF),
                                    fontSize: isTablet ? 16 : 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email,
                                    color: const Color(0xFF6366F1),
                                    size: isTablet ? 28 : 24,
                                  ),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      isTablet ? 16 : 12,
                                    ),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF4C4980),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      isTablet ? 16 : 12,
                                    ),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF6366F1),
                                      width: 2,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      isTablet ? 16 : 12,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: isTablet ? 20 : 16,
                                    horizontal: isTablet ? 20 : 16,
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),

                              SizedBox(height: isTablet ? 24 : 20),

                              // Password Field
                              TextField(
                                controller: _passwordController,
                                obscureText: !_passwordVisible,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 18 : 16,
                                ),
                                decoration: InputDecoration(
                                  labelText: "Password",
                                  labelStyle: TextStyle(
                                    color: const Color(0xFFB8B5FF),
                                    fontSize: isTablet ? 16 : 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: const Color(0xFF6366F1),
                                    size: isTablet ? 28 : 24,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _passwordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: const Color(0xFFB8B5FF),
                                      size: isTablet ? 28 : 24,
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
                                    borderRadius: BorderRadius.circular(
                                      isTablet ? 16 : 12,
                                    ),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF4C4980),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      isTablet ? 16 : 12,
                                    ),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF6366F1),
                                      width: 2,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      isTablet ? 16 : 12,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: isTablet ? 20 : 16,
                                    horizontal: isTablet ? 20 : 16,
                                  ),
                                ),
                                keyboardType: TextInputType.visiblePassword,
                              ),

                              SizedBox(height: isTablet ? 32 : 24),

                              // Login Button
                              SizedBox(
                                height: isTablet ? 64 : 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6366F1),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        isTablet ? 16 : 12,
                                      ),
                                    ),
                                    elevation: 6,
                                    disabledBackgroundColor: const Color(
                                      0xFF6366F1,
                                    ).withOpacity(0.6),
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          width: isTablet ? 28 : 24,
                                          height: isTablet ? 28 : 24,
                                          child:
                                              const CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                        )
                                      : Text(
                                          "Secure Login",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: isTablet ? 20 : 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Security Note
                      SizedBox(height: isTablet ? 32 : 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shield,
                            color: const Color(0xFF10B981),
                            size: isTablet ? 20 : 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Your data is encrypted and secure",
                            style: TextStyle(
                              color: const Color(0xFF10B981),
                              fontSize: isTablet ? 16 : 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// End of file
