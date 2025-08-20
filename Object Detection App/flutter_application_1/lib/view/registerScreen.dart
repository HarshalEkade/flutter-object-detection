
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Register extends StatefulWidget {
  const Register({super.key});
  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool showPassword = false;
  bool loading = false;

  Future<void> _register() async {
    final email = _email.text.trim();
    final pass = _password.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.red, content: Text("Please fill all fields")),
      );
      return;
    }
    setState(() => loading = true);
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: pass);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.green, content: Text("User Registered Successfully")),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(e.message ?? "Registration failed")),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(color: Colors.deepPurpleAccent),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  IconButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
                  ),
                  const Spacer(),
                  Text("Register Account", style: GoogleFonts.raleway(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
                  const Spacer(),
                ]),
                const SizedBox(height: 32),
                Text("Email Address", style: GoogleFonts.raleway(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 10),
                _filled(
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: "Enter your email", border: InputBorder.none),
                  ),
                ),
                const SizedBox(height: 18),
                Text("Password", style: GoogleFonts.raleway(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 10),
                _filled(
                  TextField(
                    controller: _password,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      hintText: "Enter your password",
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => showPassword = !showPassword),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D6EFD),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: loading
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text("Register", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 18),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Already have an account? ", style: GoogleFonts.raleway(fontSize: 15, color: Colors.white)),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: Text("Log In", style: GoogleFonts.raleway(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.yellowAccent)),
                  ),
                ]),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _filled(Widget child) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      height: 56,
      child: Center(child: child),
    );
  }
}
