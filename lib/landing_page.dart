import 'package:flutter/material.dart';
import 'sections/hero_section.dart';
import 'sections/courses_section.dart';
import 'sections/contact_form.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.network(
                  'https://cdn.discordapp.com/attachments/1082012060210188418/1321872447208947762/LogoBridge.png?ex=676ed126&is=676d7fa6&hm=f33723d0deb7c7e2e70ee7c67af5b3cb4ab913d7c452285312a231d7b0fed95d&',
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

class RegisterButton extends StatelessWidget {
  const RegisterButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD81B60), // Magenta color
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Text(
          'REGISTER NOW',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
