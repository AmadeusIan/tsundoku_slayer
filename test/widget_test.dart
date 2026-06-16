// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsundoku_slayer/services/database_helper.dart';
import 'package:tsundoku_slayer/main.dart';

class MockDatabaseHelper extends DatabaseHelper {
  MockDatabaseHelper() : super.internal();

  @override
  Future<Map<String, dynamic>> getUserProfile() async {
    return {
      'username': 'King Test',
      'current_exp': 10,
      'current_level': 2,
      'current_streak': 3,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getActiveBooks() async {
    return [
      {
        'id': 1,
        'title': 'Test Grimoire',
        'total_pages': 100,
        'current_page': 10,
        'target_days': 10,
        'status': 'ACTIVE',
      }
    ];
  }

  @override
  Future<int> insertBook(Map<String, dynamic> row) async {
    return 1;
  }

  @override
  Future<Map<String, dynamic>> completeReadingSession({
    required int bookId,
    required int pagesRead,
  }) async {
    return {'levelsGained': 0, 'suggestedBook': null};
  }

  @override
  Future<List<Map<String, dynamic>>> getBacklogBooks() async {
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> getAllBooks() async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> buyItem({
    required String itemCode,
    required int price,
    required int maxLimit,
  }) async {
    return {'status': 'SUCCESS', 'message': 'Mock buy success'};
  }

  @override
  Future<Map<String, int>> getInventory() async {
    return {'STREAK_SHIELD': 0, 'REVIVE_POTION': 0};
  }

  @override
  Future<String> evaluateDailyStreak() async {
    return 'ALREADY_EVALUATED';
  }
}

void main() {
  setUp(() {
    DatabaseHelper.instance = MockDatabaseHelper();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TsundokuSlayerApp());
    await tester.pumpAndSettle();

    // Memverifikasi bahwa aplikasi berhasil dirender tanpa error
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('King Test'), findsOneWidget);
    expect(find.text('Level 2 Slayer'), findsOneWidget);
    expect(find.text('Test Grimoire'), findsOneWidget);
  });
}
