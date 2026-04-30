import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/mascot_eyes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FocusNode _userFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isAverted = false;
  Offset _cursorPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _userFocus.addListener(_onFocusChange);
    _passFocus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _userFocus.dispose();
    _passFocus.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isAverted = _userFocus.hasFocus || _passFocus.hasFocus;
      });
    }
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: MouseRegion(
        onHover: (event) => setState(() => _cursorPosition = event.position),
        child: Row(
          children: [
            // 1. LEFT SIDE - Mascot Eyes
            Expanded(
              child: Container(
                color: Colors.white,
                child: Center(
                  child: MascotEyes(
                    isAverted: _isAverted,
                    cursorPosition: _cursorPosition,
                  ),
                ),
              ),
            ),

          // 2. RIGHT SIDE - Widenable Login Panel
          Container(
            width: 550, // <--- EDIT THIS to change the background width
            height: double.infinity,
            color: const Color(0xFFFFD509).withValues(alpha: 0.5),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Top Yellow Section with Logo
                  Container(
                    height: 240,
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo_full.png',
                        height: 180,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // Bottom Blue Section
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(minHeight: screenHeight - 240),
                    decoration: const BoxDecoration(
                      color: AppColors.loginNavyDark,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(200)),
                    ),
                    padding: const EdgeInsets.fromLTRB(50, 50, 50, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end, // Aligns the form container to the right
                      children: [
                        // FIXED WIDTH FORM CONTAINER
                        SizedBox(
                          width: 420, // <--- THE FORM STAYS THIS SIZE
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              const Text(
                                "Welcome back please login to your account",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Montserrat',
                                ),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 40),
                              
                              _buildTextField("User Name", _usernameController, _userFocus, false),
                              const SizedBox(height: 15),
                              _buildTextField("Password", _passwordController, _passFocus, true),
                              
                              const SizedBox(height: 15),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Checkbox(
                                          value: _rememberMe,
                                          onChanged: (val) => setState(() => _rememberMe = val!),
                                          side: const BorderSide(color: Colors.white, width: 2),
                                          activeColor: const Color(0xFFFFC400),
                                        ),
                                        const Flexible(
                                          child: Text(
                                            "Remember Me", 
                                            style: TextStyle(color: Colors.white, fontSize: 13),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      "Forgot Password",
                                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 35),
                              _buildLoginButton(),
                              
                              const SizedBox(height: 15),
                              Center(
                                child: Text.rich(
                                  TextSpan(
                                    text: "Don't have an account? ",
                                    children: [
                                      TextSpan(
                                        text: "Signup",
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 50), 
                        const Center(
                          child: Text(
                            "Created by Jose Rizal University 2nd years of 204I",
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildTextField(String hint, TextEditingController controller, FocusNode focusNode, bool isPassword) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: isPassword,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 16),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC400), Color(0xFFFFAE16)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Log In",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
      ),
    );
  }
}
