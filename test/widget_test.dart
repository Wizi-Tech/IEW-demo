import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hotel_app/main.dart';
import 'package:hotel_app/screens/select_hotel_screen.dart';
import 'package:hotel_app/widgets/hotel_card.dart';

void main() {
  testWidgets('Hotel App UI smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HotelApp());

    // Verify that the SelectHotelScreen is present.
    expect(find.byType(SelectHotelScreen), findsOneWidget);

    // Verify that the title is correct.
    expect(find.text('Select Hotel'), findsOneWidget);

    // Verify that we have HotelCards.
    expect(find.byType(HotelCard), findsWidgets);

    // Verify specific text from the cards exists
    expect(find.text('Taj Exotica Resort & Spa'), findsOneWidget);
    expect(find.text('Available Jan 2025 - Dec 2026'), findsWidgets);
    expect(find.text('Select'), findsWidgets);
  });
}
