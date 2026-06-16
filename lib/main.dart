import 'package:flutter/material.dart';
import 'main_navigation.dart';
import 'notification_helper.dart';

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
        scaffoldBackgroundColor: const Color(0xFFF5F5DC),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFB7C5)),
        useMaterial3: true,
      ),
      home: const MainNavigation(), // Mengarahkan ke sistem navigasi utama
    );
  }
}