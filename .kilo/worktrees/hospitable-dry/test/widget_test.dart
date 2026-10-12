import 'package:fixa/app/fixa_app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Fixa splash renders logo', (tester) async {
    await tester.pumpWidget(const FixaApp());

    expect(find.text('Fixa'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
  });
}
