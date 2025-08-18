import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';

void main() {
  runApp(const SignupWithOtpApp());
}

class SignupWithOtpApp extends StatelessWidget {
  const SignupWithOtpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Rides - Sign Up',
      theme: ThemeData(
        primaryColor: const Color(0xFF4F46E5),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const SignupWithOtpPage(),
    );
  }
}

class SignupWithOtpPage extends StatefulWidget {
  const SignupWithOtpPage({super.key});

  @override
  State<SignupWithOtpPage> createState() => _SignupWithOtpPageState();
}

class _SignupWithOtpPageState extends State<SignupWithOtpPage> {
  int currentStep = 1;
  bool isLoading = false;
  String currentEmail = '';

  // Form controllers
  final _registrationFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final studentIdController = TextEditingController();
  final gradYearController = TextEditingController();
  final otpController = TextEditingController();

  // Phone number handling
  PhoneNumber phoneNumber = PhoneNumber(isoCode: 'IN');
  String formattedPhoneNumber = '';
  bool isPhoneNumberValid = false;
  bool hasSubmitted = false; // Track form submission attempts

  final String backendUrl = 'http://localhost:3000';

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    studentIdController.dispose();
    gradYearController.dispose();
    otpController.dispose();
    super.dispose();
  }

  // Custom validation function for Indian phone numbers
  bool _isValidIndianPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return false;

    // Remove all non-digit characters
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Check if it's a valid Indian mobile number
    // Indian mobile numbers start with 6, 7, 8, or 9 and are 10 digits long
    // With country code: +91 followed by 10 digits
    if (cleanNumber.startsWith('91') && cleanNumber.length == 12) {
      String actualNumber = cleanNumber.substring(2);
      return RegExp(r'^[6-9]\d{9}$').hasMatch(actualNumber);
    } else if (cleanNumber.length == 10) {
      return RegExp(r'^[6-9]\d{9}$').hasMatch(cleanNumber);
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          _buildHeader(screenWidth),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                child: Center(
                  child: SizedBox(
                    width: screenWidth > 600 ? 480 : double.infinity,
                    child: Column(
                      children: [
                        _buildStepIndicator(screenWidth),
                        SizedBox(height: screenHeight * 0.04),
                        currentStep == 1
                            ? _buildRegistrationStep(screenWidth, screenHeight)
                            : currentStep == 2
                            ? _buildOtpInputStep(screenWidth, screenHeight)
                            : _buildOtpStep(screenWidth, screenHeight),

                        SizedBox(height: screenHeight * 0.04),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildSimpleFooter(screenWidth),
        ],
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Uni - Rides',
                style: TextStyle(
                  fontSize: screenWidth < 400 ? 20 : 24,
                  fontFamily: 'Pacifico',
                  color: const Color(0xFF4F46E5),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '@vit.edu only',
                  style: TextStyle(
                    color: const Color(0xFF4F46E5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepCircle(1, true, screenWidth),
        _buildStepLine(currentStep >= 2, screenWidth),
        _buildStepCircle(2, currentStep >= 2, screenWidth),
      ],
    );
  }

  Widget _buildStepCircle(int step, bool isActive, double screenWidth) {
    return Container(
      width: screenWidth < 400 ? 28 : 32,
      height: screenWidth < 400 ? 28 : 32,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$step',
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
            fontSize: screenWidth < 400 ? 12 : 14,
          ),
        ),
      ),
    );
  }

  Widget _buildStepLine(bool isActive, double screenWidth) {
    return Container(
      width: screenWidth < 400 ? 48 : 64,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4F46E5) : const Color(0xFFD1D5DB),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildRegistrationStep(double screenWidth, double screenHeight) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(screenWidth * 0.06),
      child: Form(
        key: _registrationFormKey,
        child: Column(
          children: [
            Column(
              children: [
                Icon(Icons.school, size: 48, color: const Color(0xFF4F46E5)),
                SizedBox(height: 16),
                Text(
                  'Join VIT University',
                  style: TextStyle(
                    fontSize: screenWidth < 400 ? 20 : 24,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  'Create your student account for campus rides',
                  style: TextStyle(
                    fontSize: screenWidth < 400 ? 14 : 16,
                    color: const Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),

            _buildTextField(
              controller: fullNameController,
              label: 'Full Name',
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Full name is required';
                if (value!.length < 2)
                  return 'Name must be at least 2 characters';
                return null;
              },
              screenWidth: screenWidth,
            ),
            SizedBox(height: screenHeight * 0.02),

            _buildTextField(
              controller: emailController,
              label: 'VIT Email (@vit.edu only)',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              helperText: 'Only @vit.edu emails are allowed',
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Email is required';
                if (!value!.endsWith('@vit.edu')) {
                  return 'Only @vit.edu emails are allowed';
                }
                return null;
              },
              screenWidth: screenWidth,
            ),
            SizedBox(height: screenHeight * 0.02),

            _buildTextField(
              controller: studentIdController,
              label: 'Student ID',
              prefixIcon: Icons.badge_outlined,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Student ID is required';
                if (value!.length < 6)
                  return 'Student ID must be at least 6 characters';
                return null;
              },
              screenWidth: screenWidth,
            ),
            SizedBox(height: screenHeight * 0.02),

            // Phone Number Field - FIXED VERSION
            _buildPhoneNumberField(screenWidth),
            SizedBox(height: screenHeight * 0.02),

            _buildTextField(
              controller: gradYearController,
              label: 'Graduation Year',
              prefixIcon: Icons.calendar_today_outlined,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true)
                  return 'Graduation year is required';
                final year = int.tryParse(value!);
                final currentYear = DateTime.now().year;
                if (year == null ||
                    year < currentYear ||
                    year > currentYear + 6) {
                  return 'Enter valid year ($currentYear-${currentYear + 6})';
                }
                return null;
              },
              screenWidth: screenWidth,
            ),
            SizedBox(height: screenHeight * 0.02),

            _buildTextField(
              controller: passwordController,
              label: 'Password',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              helperText: 'Minimum 6 characters',
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Password is required';
                if (value!.length < 6)
                  return 'Password must be at least 6 characters';
                return null;
              },
              screenWidth: screenWidth,
            ),
            SizedBox(height: screenHeight * 0.03),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _createAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Creating Account...'),
                        ],
                      )
                    : const Text('Create Account'),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: screenWidth < 400 ? 13 : 14,
                    color: const Color(0xFF6B7280),
                  ),
                  children: [
                    const TextSpan(text: 'Already have an account? '),
                    TextSpan(
                      text: 'Sign in',
                      style: TextStyle(
                        color: const Color(0xFF4F46E5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneNumberField(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number (for password reset)',
          style: TextStyle(
            fontSize: screenWidth < 400 ? 13 : 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: hasSubmitted && !isPhoneNumberValid
                  ? Colors.red
                  : const Color(0xFFD1D5DB),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: InternationalPhoneNumberInput(
            onInputChanged: (PhoneNumber number) {
              setState(() {
                formattedPhoneNumber = number.phoneNumber ?? '';
                // Update validation status using our custom validator
                isPhoneNumberValid = _isValidIndianPhoneNumber(
                  formattedPhoneNumber,
                );
              });
            },
            // CRITICAL FIX: Remove the built-in validator to prevent error messages
            validator: (value) => null,
            selectorConfig: const SelectorConfig(
              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
              setSelectorButtonAsPrefixIcon: true,
              leadingPadding: 16,
            ),
            ignoreBlank: false,
            // CRITICAL FIX: Disable auto-validation completely
            autoValidateMode: AutovalidateMode.disabled,
            selectorTextStyle: const TextStyle(color: Colors.black),
            initialValue: phoneNumber,
            formatInput: true,
            keyboardType: const TextInputType.numberWithOptions(
              signed: true,
              decimal: true,
            ),
            inputDecoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter phone number',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        // Show custom error message only after submission attempt
        if (hasSubmitted && !isPhoneNumberValid)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              'Please enter a valid 10-digit Indian mobile number.',
              style: TextStyle(color: Colors.red[700], fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildOtpStep(double screenWidth, double screenHeight) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(screenWidth * 0.06),
      child: Form(
        key: _otpFormKey,
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: const Color(0xFF10B981),
            ),
            SizedBox(height: 16),
            Text(
              'Account Created Successfully!',
              style: TextStyle(
                fontSize: screenWidth < 400 ? 20 : 24,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              'Welcome to VIT University ride sharing community!',
              style: TextStyle(
                fontSize: screenWidth < 400 ? 14 : 16,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.03),

            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.email,
                        color: const Color(0xFF10B981),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Verification email sent to $currentEmail',
                          style: TextStyle(color: const Color(0xFF059669)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        color: const Color(0xFF10B981),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Phone saved for password reset: $formattedPhoneNumber',
                          style: TextStyle(color: const Color(0xFF059669)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(Icons.login),
                label: Text('Go to Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpInputStep(double screenWidth, double screenHeight) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(screenWidth * 0.06),
      child: Form(
        key: _otpFormKey,
        child: Column(
          children: [
            Icon(
              Icons.email_outlined,
              size: 48,
              color: const Color(0xFF4F46E5),
            ),
            SizedBox(height: 16),
            Text(
              'Verify Your Email',
              style: TextStyle(
                fontSize: screenWidth < 400 ? 20 : 24,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              'Enter the 6-digit code sent to $currentEmail',
              style: TextStyle(
                fontSize: screenWidth < 400 ? 14 : 16,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.03),
            _buildTextField(
              controller: otpController,
              label: 'OTP Code',
              prefixIcon: Icons.security,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.length != 6) {
                  return 'Please enter a valid 6-digit code';
                }
                return null;
              },
              screenWidth: screenWidth,
            ),
            SizedBox(height: screenHeight * 0.03),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (_otpFormKey.currentState!.validate()) {
                          await _verifyOtp();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Verifying...'),
                        ],
                      )
                    : const Text('Verify OTP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // 👆 END OF NEW METHOD 👆

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? helperText,
    bool obscureText = false,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    String? Function(String?)? validator,
    required double screenWidth,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: screenWidth < 400 ? 13 : 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: const Color(0xFF6B7280))
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            helperText: helperText,
            helperStyle: TextStyle(
              fontSize: screenWidth < 400 ? 11 : 12,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleFooter(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF374151), const Color(0xFF1F2937)],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: 16,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Uni-Rides',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth < 400 ? 16 : 18,
                  fontFamily: 'Pacifico',
                ),
              ),
              const SizedBox(width: 8),
              const Text('🚗', style: TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '© 2025 Uni-Rides. All rights reserved.',
            style: TextStyle(
              color: Colors.white54,
              fontSize: screenWidth < 400 ? 9 : 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _createAccount() async {
    setState(() {
      hasSubmitted = true;
    });

    if (!_registrationFormKey.currentState!.validate()) return;
    if (!isPhoneNumberValid) {
      _showNotification(
        'Please enter a valid 10-digit Indian phone number',
        false,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$backendUrl/api/signup/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fullName': fullNameController.text.trim(),
          'email': emailController.text.trim().toLowerCase(),
          'password': passwordController.text,
          'studentId': studentIdController.text.trim(),
          'phoneNumber': formattedPhoneNumber,
          'college': 'VIT University', // FIELD NAME matches backend!
          'collegeDomain': 'vit.edu',
          'gradYear': int.parse(gradYearController.text.trim()),
        }),
      );

      if (response.statusCode == 200) {
        // OTP sent, advance to OTP verification step
        setState(() {
          currentStep = 2;
          currentEmail = emailController.text.trim();
          isLoading = false;
        });
        _showNotification('OTP sent to your email! Please verify.', true);
      } else {
        final error = json.decode(response.body);
        _showNotification(error['message'] ?? 'Signup failed.', false);
        setState(() => isLoading = false);
      }
    } catch (e) {
      _showNotification('Signup request failed. Please try again.', false);
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveToMongoDB(String firebaseUid) async {
    try {
      print('Attempting to save to MongoDB...'); // Debug log

      final response = await http
          .post(
            Uri.parse('$backendUrl/api/users'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'email': emailController.text.trim().toLowerCase(),
              'fullName': fullNameController.text.trim(),
              'studentId': studentIdController.text.trim(),
              'phoneNumber': formattedPhoneNumber,
              'college': 'VIT University', // Corrected field name
              'collegeDomain': 'vit.edu',
              'graduationYear': int.parse(
                gradYearController.text.trim(),
              ), // Corrected field name
              'createdAt': DateTime.now().toIso8601String(),
              'isEmailVerified': false,
              'isPhoneVerified': false,
            }),
          )
          .timeout(Duration(seconds: 10));

      print('MongoDB response status: ${response.statusCode}');
      print('MongoDB response body: ${response.body}');

      if (response.statusCode != 201) {
        throw Exception('Failed to save to MongoDB: ${response.body}');
      }

      print('Successfully saved to MongoDB!');
    } catch (e) {
      print('MongoDB save error: $e');
      throw e;
    }
  }

  Future<void> _verifyOtp() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$backendUrl/api/signup/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': currentEmail, // this is the user's email being verified
          'otp': otpController.text.trim(),
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          currentStep = 3; // Show existing _buildOtpStep (your success UI)
          isLoading = false;
        });
        _showNotification('Account created successfully!', true);
      } else {
        final error = json.decode(response.body);
        _showNotification(
          error['message'] ?? 'OTP verification failed.',
          false,
        );
      }
    } catch (e) {
      _showNotification('Verification failed, please try again.', false);
    }
    setState(() => isLoading = false);
  }

  void _showNotification(String message, bool isSuccess) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
