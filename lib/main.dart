import 'package:flutter/material.dart';
import 'dashboard_screen.dart'; // Menyambungkan file baru

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Wajib ditambahkan jika pakai SQLite
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
        scaffoldBackgroundColor: const Color(0xFFF5F5DC),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFB7C5)),
        useMaterial3: true,
      ),
      home: const DashboardScreen(), // Mengarahkan ke layar Dashboard
    );
  }
}