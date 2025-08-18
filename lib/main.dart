import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'homepage.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const UniRidesApp());
}

class UniRidesApp extends StatelessWidget {
  const UniRidesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uni-Rides',
      theme: ThemeData(
        primaryColor: const Color(0xFF4F46E5),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is logged in AND email is verified, go to HomePage
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          
          // CHECK EMAIL VERIFICATION STATUS
          if (user.emailVerified) {
            return const HomePage();
          } else {
            // User exists but email not verified - show verification page
            return EmailVerificationPage(user: user);
          }
        }

        // If user is not logged in, go to LoginPage
        return const LoginPage();
      },
    );
  }
}

// NEW: Email Verification Page
class EmailVerificationPage extends StatefulWidget {
  final User user;
  
  const EmailVerificationPage({super.key, required this.user});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool isResending = false;
  
  @override
  void initState() {
    super.initState();
    // Check verification status periodically
    _checkEmailVerification();
  }

  void _checkEmailVerification() {
    Timer.periodic(Duration(seconds: 3), (timer) async {
      await widget.user.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        timer.cancel();
        // Email verified - AuthWrapper will automatically redirect to HomePage
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.email_outlined,
                size: 80,
                color: const Color(0xFF4F46E5),
              ),
              SizedBox(height: 24),
              Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF374151),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'We sent a verification link to:',
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 8),
              Text(
                widget.user.email!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4F46E5),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Please check your email and click the verification link to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: isResending ? null : _resendVerificationEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: isResending 
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Sending...'),
                        ],
                      )
                    : Text('Resend Verification Email'),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                child: Text(
                  'Use Different Email',
                  style: TextStyle(color: const Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => isResending = true);
    
    try {
      await widget.user.sendEmailVerification();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification email sent! Please check your inbox.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send verification email. Try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    setState(() => isResending = false);
  }
}
