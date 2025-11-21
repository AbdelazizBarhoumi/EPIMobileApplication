import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/controllers/auth_controller.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLogin = true;
  bool _isLoading = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Define the primary color for consistency (Red[900] from your style)
  final Color primaryColor = Colors.red[900]!;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleFormType() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  String? _validateInputs() {
    if (!_isLogin && nameController.text.trim().isEmpty) {
      return 'Name is required';
    }
    if (emailController.text.trim().isEmpty) {
      return 'Email is required';
    }
    if (!_isValidEmail(emailController.text.trim())) {
      return 'Please enter a valid email';
    }
    if (passwordController.text.isEmpty) {
      return 'Password is required';
    }
    if (passwordController.text.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!_isLogin) {
      if (confirmPasswordController.text.isEmpty) {
        return 'Confirm password is required';
      }
      if (passwordController.text != confirmPasswordController.text) {
        return 'Passwords do not match';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Stack(
                children: [
                  // --- Top Background Image/Color (Restored exactly as requested) ---
                  Container(
                    width: MediaQuery.of(context).size.width * 1,
                    height: MediaQuery.of(context).size.height * 0.5,
                    decoration: BoxDecoration(
                      color: Colors.red[900],
                      boxShadow: const [
                        BoxShadow(blurRadius: 5.0, color: Colors.grey)
                      ],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40.0),
                        bottomRight: Radius.circular(40.0),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      child: Image(
                        image: const AssetImage("assets/epiDigitale.jpg"),
                        fit: BoxFit.fill,
                        color: Colors.grey.withOpacity(0.35),
                        colorBlendMode: BlendMode.modulate,
                        errorBuilder: (c, e, s) => Container(color: Colors.red[900]),
                      ),
                    ),
                  ),
                  Align(
                    child: Column(children: [
                      // --- Logo Section ---
                      Container(
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.1,
                            bottom: 0),
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: MediaQuery.of(context).size.width * 0.45,
                        decoration: BoxDecoration(
                          //color: Colors.white,
                          boxShadow: const [
                            BoxShadow(blurRadius: 100.0, color: Colors.white)
                          ],
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Image.asset(
                          "assets/logo-epi.png",
                          errorBuilder: (c, e, s) => Icon(Icons.school, size: 60, color: Colors.white),
                        ),
                      ),

                      // --- School Name Text ---
                      Container(
                        margin: const EdgeInsets.all(20),
                        child: const Column(children: [
                          Text(
                            "Epi Educational Group",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Rowdies",
                                fontSize: 20),
                          ),
                          Text(
                            "Route de Ceinture, Sahloul Sousse 4021",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "SourceSerifLight",
                                fontWeight: FontWeight.bold,
                                fontSize: 17),
                          )
                        ]),
                      ),

                      // --- Login Card (White Background) ---
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        margin: const EdgeInsets.only(bottom: 30),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(blurRadius: 5.0, color: Colors.grey)
                          ],
                          borderRadius: BorderRadius.circular(30.0),
                          color: Colors.white,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                                child: Text(
                                  _isLogin ? "Welcome Back" : "Welcome",
                                  key: ValueKey<bool>(_isLogin),
                                  style: TextStyle(
                                      color: primaryColor, // Changed to Red for visibility on White
                                      fontFamily: "Rowdies",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25),
                                ),
                              ),
                              Container(
                                  margin: const EdgeInsets.all(15),
                                  child: Text(
                                    "Please log in using your registered account first to access the campus portal",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: "SourceSerifLight",
                                        color: Colors.grey[600]), // Changed to Grey for visibility
                                  )),
                              const SizedBox(height: 20),

                              // --- Inputs (Enhanced Visibility) ---
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) => SizeTransition(
                                  sizeFactor: animation,
                                  child: FadeTransition(opacity: animation, child: child),
                                ),
                                child: !_isLogin ? Column(
                                  key: const ValueKey('name_field'),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: TextField(
                                        controller: nameController,
                                        style: const TextStyle(color: Colors.black),
                                        cursorColor: primaryColor,
                                        decoration: _buildInputDecoration("Name", "Enter your name", Icons.person),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                  ],
                                ) : const SizedBox(key: ValueKey('empty')),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: TextField(
                                  controller: emailController,
                                  style: const TextStyle(color: Colors.black),
                                  cursorColor: primaryColor,
                                  decoration: _buildInputDecoration("Email", "Enter your email", Icons.email),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: TextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  style: const TextStyle(color: Colors.black),
                                  cursorColor: primaryColor,
                                  decoration: _buildInputDecoration("Password", "Enter your password", Icons.lock),
                                ),
                              ),
                              const SizedBox(height: 15),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) => SizeTransition(
                                  sizeFactor: animation,
                                  child: FadeTransition(opacity: animation, child: child),
                                ),
                                child: !_isLogin ? Column(
                                  key: const ValueKey('confirm_password'),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: TextField(
                                        controller: confirmPasswordController,
                                        obscureText: true,
                                        style: const TextStyle(color: Colors.black),
                                        cursorColor: primaryColor,
                                        decoration: _buildInputDecoration("Confirm Password", "Confirm your password", Icons.lock_outline),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ) : const SizedBox(key: ValueKey('spacer'), height: 20),
                              ),

                              // --- Button ---
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor, // Red background
                                  foregroundColor: Colors.white, // White text
                                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                                ),
                                onPressed: () async {
                                  // Validate inputs
                                  String? validationError = _validateInputs();
                                  if (validationError != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(validationError))
                                    );
                                    return;
                                  }

                                  final authController = context.read<AuthController>();

                                  setState(() {
                                    _isLoading = true;
                                  });

                                  bool success;
                                  if (_isLogin) {
                                    success = await authController.login(
                                      emailController.text.trim(),
                                      passwordController.text
                                    );
                                  } else {
                                    success = await authController.register(
                                      name: nameController.text.trim(),
                                      email: emailController.text.trim(),
                                      password: passwordController.text,
                                      passwordConfirmation: passwordController.text,
                                      majorId: 1, // TODO: Get from form
                                      yearLevel: 1, // TODO: Get from form
                                      academicYear: '2024-2025',
                                      classLevel: 'L1',
                                    );
                                  }

                                  setState(() {
                                    _isLoading = false;
                                  });

                                  if (success) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => const HomePage())
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(authController.errorMessage ?? 'Authentication failed'),
                                        backgroundColor: Colors.red,
                                      )
                                    );
                                  }
                                },
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2,
                                )
                                    : AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                                  child: Text(
                                    _isLogin ? "Login" : "Sign Up",
                                    key: ValueKey<bool>(_isLogin),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),

                              // --- Toggle ---
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _isLogin ? "Don't have an account?" : "Already have an account?",
                                    style: TextStyle(color: Colors.grey[600]), // Visible on white
                                  ),
                                  TextButton(
                                    onPressed: _toggleFormType,
                                    style: TextButton.styleFrom(
                                      foregroundColor: primaryColor,
                                    ),
                                    child: Text(
                                      _isLogin ? 'Sign Up' : 'Login',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to style input fields consistently (Dark text for White background)
  InputDecoration _buildInputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[700]),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(icon, color: primaryColor),
      filled: true,
      fillColor: Colors.grey[50],
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor, width: 2),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
    );
  }
}
