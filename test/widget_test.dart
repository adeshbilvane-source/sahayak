import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Relative path se main.dart ko import kar rahe hain
import 'package:my_first_project/main.dart'; 

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Humari nayi NeuroNestApp ko test environment mein build karega
    await tester.pumpWidget(const NeuroNestApp());

    // Check karega ki app bina crash hue start ho rahi hai ya nahi
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}