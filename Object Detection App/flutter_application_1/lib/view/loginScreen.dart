
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool hide = true;
  bool loading = false;

  Future<void> _login() async {
    final email = emailController.text.trim();
    final pass = passController.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.orange, content: Text("Please enter both email and password")),
      );
      return;
    }

    // Hardcoded fallback per task spec
    if (email.toLowerCase() == 'test@example.com' && pass == '123456') {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/detection');
      }
      return;
    }
    setState(() => loading = true);
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: pass);
      log('Signed in: ${cred.user?.email}');
      if (mounted) Navigator.pushReplacementNamed(context, '/detection');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(e.message ?? "Login failed")),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hintColor = const Color.fromRGBO(124, 124, 124, 1);
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(25),
        children: [
          const SizedBox(height: 40),
          Text("Login", style: GoogleFonts.dmSans(fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text("Enter your email and password",
              style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w400, color: hintColor)),
          const SizedBox(height: 24),

          // Email
          Text("Email", style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700, color: hintColor)),
          const SizedBox(height: 8),
          _input(
            child: TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: "abc@gmail.com", border: InputBorder.none),
              style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),

          const SizedBox(height: 18),

          // Password
          Text("Password", style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700, color: hintColor)),
          const SizedBox(height: 8),
          _input(
            child: TextField(
              controller: passController,
              obscureText: hide,
              decoration: InputDecoration(
                hintText: "********",
                border: InputBorder.none,
                suffixIcon: IconButton(
                  onPressed: () => setState(() => hide = !hide),
                  icon: Icon(hide ? Icons.visibility_off_outlined : Icons.remove_red_eye_outlined),
                ),
              ),
              style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),

          const SizedBox(height: 32),

          // Login button
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: loading ? null : _login,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF53B175), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: loading
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text("Log In", style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),

          const SizedBox(height: 18),

          // Go to register
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text("Don't have an account?", style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/register'),
              child: Text("Sign Up", style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.green)),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _input({required Widget child}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(offset: Offset(0, 2), color: Color.fromRGBO(0, 0, 0, 0.04))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Center(child: child),
    );
  }
}


