import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sections/hero_section.dart';
import 'sections/courses_section.dart';
import 'sections/contact_form.dart';
import 'admin/admin_panel.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          ElevatedButton(
            onPressed: () async {
              // Check if user is already signed in
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminPanel()),
                );
              } else {
                // If not signed in, show login dialog
                bool? result = await showDialog<bool>(
                  context: context,
                  builder: (context) => const AdminLoginDialog(),
                );
                if (result == true) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminPanel()),
                  );
                }
              }
            },
            child: const Text('Admin'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD81B60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/logo.png',
                  height: 45,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const HeroSection(),
            const CoursesSection(),
            const ContactForm(),
          ],
        ),
      ),
    );
  }
}

class AdminLoginDialog extends StatefulWidget {
  const AdminLoginDialog({Key? key}) : super(key: key);

  @override
  _AdminLoginDialogState createState() => _AdminLoginDialogState();
}

class _AdminLoginDialogState extends State<AdminLoginDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid credentials')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Admin Login'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _login,
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Login'),
        ),
      ],
    );
  }
}

