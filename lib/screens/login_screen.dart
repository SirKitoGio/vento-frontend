import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  final TextEditingController _emailController = TextEditingController();
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
    _emailController.dispose();
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
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and password")),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An unexpected error occurred"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    final mascotWidget = Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 0),
          child: FittedBox(
            fit: BoxFit.contain,
            child: MascotEyes(
              isAverted: _isAverted,
              cursorPosition: _cursorPosition,
            ),
          ),
        ),
      ),
    );

    final loginForm = Container(
      width: isMobile ? double.infinity : 550,
      height: double.infinity,
      color: const Color(0xFFFFD509).withValues(alpha: 0.5),
      child: Column(
        children: [
          Container(
            height: isMobile ? 180 : 200,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Image.asset(
                'assets/images/logo_full.png',
                height: isMobile ? 120 : 150,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.loginNavyDark,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(200),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                isMobile ? 30 : 50, 
                60, 
                isMobile ? 30 : 50, 
                20
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: isMobile ? double.infinity : 380,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        const Text(
                          "Welcome back please login to your account",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: 'Montserrat',
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 30),
                        _buildTextField("Email Address", _emailController, _userFocus, false),
                        const SizedBox(height: 12),
                        _buildTextField("Password", _passwordController, _passFocus, true),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (val) => setState(() => _rememberMe = val!),
                                    side: const BorderSide(color: Colors.white, width: 2),
                                    activeColor: const Color(0xFFFFC400),
                                  ),
                                ),
                                const Text("Remember Me", style: TextStyle(color: Colors.white, fontSize: 13)),
                              ],
                            ),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                              child: Text(
                                "Forgot Password",
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        _buildLoginButton(),
                        const SizedBox(height: 12),
                        Center(
                          child: Text.rich(
                            TextSpan(
                              text: "Don't have an account? ",
                              children: const [
                                TextSpan(
                                  text: "Signup",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.only(top: 40, bottom: 20),
                    child: Center(
                      child: Text(
                        "Created by Jose Rizal University 2nd years of 204I",
                        style: TextStyle(
                          color: Colors.white24,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onPanUpdate: (details) {
          if (isMobile) {
            setState(() => _cursorPosition = details.globalPosition);
          }
        },
        onTapDown: (details) {
          if (isMobile) {
            setState(() => _cursorPosition = details.globalPosition);
          }
        },
        child: MouseRegion(
          onHover: (event) => setState(() => _cursorPosition = event.position),
          child: isMobile 
            ? loginForm
            : Row(
                children: [
                  Expanded(child: mascotWidget),
                  loginForm,
                ],
              ),
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
