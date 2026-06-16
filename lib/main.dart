import 'package:flutter/material.dart';
import 'services/notification_helper.dart';
import 'main_navigation.dart';
import 'views/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Wajib ditambahkan jika pakai SQLite
  await NotificationHelper.instance.init();
  runApp(const TsundokuSlayerApp());
}

class TsundokuSlayerApp extends StatelessWidget {
  const TsundokuSlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tsundoku Slayer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Menjadikan Quicksand sebagai font utama (bulat, cozy, ramah)
        textTheme: GoogleFonts.quicksandTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.lora(
            color: const Color(0xFF5D4037), // warmBrown
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Mengarahkan ke Splash Screen terlebih dahulu
    );
  }
}