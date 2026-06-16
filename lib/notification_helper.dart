import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
import 'package:flutter/material.dart';

class NotificationHelper {
  NotificationHelper._privateConstructor();
  static final NotificationHelper instance = NotificationHelper._privateConstructor();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Inisialisasi engine waktu presisi
    tz.initializeTimeZones();
    try {
      final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Sihir timezone gagal dilacak: $e');
    }

    // 2. Setup ikon dasar
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    } else if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> scheduleNightMissions(bool hasReadToday, bool hasShield, bool isVacationActive) async {
    // Pertama, hanguskan semua janji palsu yang pernah terucap
    await flutterLocalNotificationsPlugin.cancelAll();

    // Aturan 1: Jika ancaman tak lagi relevan, pergi dengan damai
    if (hasReadToday || isVacationActive) {
      return;
    }

    // Aturan 2: Susun rencana darurat hari ini
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    // Misi I: 21:00 (Peringatan Awal)
    tz.TZDateTime schedule21 = tz.TZDateTime(tz.local, now.year, now.month, now.day, 21, 0);
    if (schedule21.isAfter(now)) {
      await _scheduleNotification(
        id: 1,
        title: '🌙 Malam Semakin Larut...',
        body: 'Angin malam berhembus dingin. Baca setidaknya 1 halaman sebelum tengah malam untuk menyelamatkan kehangatan pohon sakuramu!',
        scheduledDate: schedule21,
      );
    }

    // Misi II: 23:00 (Kepanikan)
    tz.TZDateTime schedule23 = tz.TZDateTime(tz.local, now.year, now.month, now.day, 23, 0);
    if (schedule23.isAfter(now)) {
      await _scheduleNotification(
        id: 2,
        title: '⏳ Waktu Hampir Habis!',
        body: 'Tinggal 1 jam lagi! Cepat buka Grimoire-mu sebelum sihirnya memudar.',
        scheduledDate: schedule23,
      );
    }

    // Misi III: 23:59 (Percabangan Takdir)
    tz.TZDateTime schedule2359 = tz.TZDateTime(tz.local, now.year, now.month, now.day, 23, 59);
    if (schedule2359.isAfter(now)) {
      final String title = hasShield ? '🛡️ Keajaiban Terjadi...' : '🍂 Musim Telah Berganti';
      final String body = hasShield
          ? 'Sihir Revive Potion-mu pecah untuk melindungi pohon sakura dari malam yang dingin.'
          : 'Pohon sakuramu tertidur pulas. Tidak apa-apa, mari tanam benih baru besok pagi.';
      await _scheduleNotification(
        id: 3,
        title: title,
        body: body,
        scheduledDate: schedule2359,
      );
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'night_mission_channel',
      'Misi Malam Hari',
      channelDescription: 'Pengingat membaca sebelum pergantian hari',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF2C3E50), // Tema Midnight Blue
      enableLights: true,
      ledColor: Color(0xFFFFB7C5), // Sakura pink LED
      ledOnMs: 1000,
      ledOffMs: 500,
    );
    
    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
