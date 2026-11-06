import 'package:flutter_test/flutter_test.dart';

import 'package:barber_platform/main.dart';

void main() {
    testWidgets('Giriş ekranı açılır', (WidgetTester tester) async {
    await tester.pumpWidget(const BarberPlatformApp());

      expect(find.text('Tekrar hoş geldin'), findsOneWidget);
      expect(find.text('Giriş yap'), findsOneWidget);
      expect(find.text('Yeni hesap oluştur'), findsOneWidget);
  });
}
