import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      body: Center(
        child: Text(
          'Tsundoku Slayer',
          style: GoogleFonts.lora(
            fontSize: 38,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5D4037),
          ),
        ),
      ),
    );
  }
}
