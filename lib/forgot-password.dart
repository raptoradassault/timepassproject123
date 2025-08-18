import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'dart:convert';
import 'login.dart';


class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // State management
  int currentStep = 1; // 1: Enter Phone, 2: Verify OTP, 3: Success
  bool isLoading = false;
  String? verificationId;
  String formattedPhoneNumber = '';

  // Controllers
  final otpController = TextEditingController();
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();
  PhoneNumber number = PhoneNumber(isoCode: 'US');

  // **IMPORTANT: REPLACE WITH YOUR ACTUAL BACKEND URL**
  final String backendUrl = 'http://localhost:3000'; // For local testing
  // final String backendUrl = 'https://your-deployed-app.com'; // For production

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  // Step 1: Check phone number and send OTP
  Future<void> _sendOTP() async {
    if (!_formKeyStep1.currentState!.validate() || formattedPhoneNumber.isEmpty) {
      _showErrorSnackBar("Please enter a valid phone number.");
      return;
    }
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$backendUrl/api/check-phone'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phoneNumber': formattedPhoneNumber}),
      );

      if (response.statusCode != 200) {
        _showErrorSnackBar("No account is associated with this phone number.");
        return;
      }

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          _showErrorSnackBar("Failed to send OTP. ${e.message}");
        },
        codeSent: (String verId, int? resendToken) {
          setState(() {
            verificationId = verId;
            currentStep = 2;
          });
        },
        codeAutoRetrievalTimeout: (String verId) {},
      );
    } catch (e) {
      _showErrorSnackBar("An error occurred. Please check your network and try again.");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Step 2: Verify OTP (This part is now simplified for password reset)
  Future<void> _verifyOTP() async {
     if (!_formKeyStep2.currentState!.validate()) return;
    
    setState(() => isLoading = true);

    try {
        final credential = PhoneAuthProvider.credential(
            verificationId: verificationId!,
            smsCode: otpController.text.trim(),
        );

        // This just verifies the user. The actual password reset is done via other means in Firebase
        // For a full implementation, you would use this credential to either sign the user in
        // and force a password change, or use a backend function.
        // For now, we confirm the OTP is valid and move to a "success" screen.
        await FirebaseAuth.instance.signInWithCredential(credential);

        // In a real app, you would now prompt for a new password.
        // For simplicity, we'll just show a success message and guide the user.
        setState(() => currentStep = 3);

    } on FirebaseAuthException catch (e) {
        _showErrorSnackBar("Invalid OTP or error verifying. ${e.message}");
    } finally {
        if (mounted) setState(() => isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Stepper(
        currentStep: currentStep - 1,
        controlsBuilder: (context, details) => Container(),
        steps: [
          _buildPhoneStep(),
          _buildVerifyStep(),
          _buildSuccessStep(),
        ],
      ),
    );
  }

  Step _buildPhoneStep() {
    return Step(
      title: const Text('Enter Phone Number'),
      isActive: currentStep == 1,
      content: Form(
        key: _formKeyStep1,
        child: Column(
          children: [
            InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber num) => formattedPhoneNumber = num.phoneNumber ?? '',
              selectorConfig: const SelectorConfig(selectorType: PhoneInputSelectorType.BOTTOM_SHEET),
              initialValue: number,
              inputDecoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              validator: (value) => (value?.trim().isEmpty ?? true) ? 'Phone number is required' : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : _sendOTP,
              child: isLoading ? const CircularProgressIndicator() : const Text('Send OTP'),
            ),
          ],
        ),
      ),
    );
  }

  Step _buildVerifyStep() {
    return Step(
      title: const Text('Verify OTP'),
      isActive: currentStep == 2,
      content: Form(
        key: _formKeyStep2,
        child: Column(
          children: [
            Text("Enter the OTP sent to $formattedPhoneNumber"),
            TextFormField(
              controller: otpController,
              decoration: const InputDecoration(labelText: 'OTP'),
              keyboardType: TextInputType.number,
              validator: (v) => v?.length != 6 ? 'Enter a 6-digit code' : null,
            ),
             const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : _verifyOTP,
              child: isLoading ? const CircularProgressIndicator() : const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }

   Step _buildSuccessStep() {
    return Step(
      title: const Text('Success'),
      isActive: currentStep == 3,
      content: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const Text('Verification Successful!'),
          const SizedBox(height: 8),
          const Text("Please use Firebase Console to reset the password for now."),
          ElevatedButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            ),
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }
}

