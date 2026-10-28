import 'package:cybercafe_app_mobile/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra la pantalla de inicio de sesión', (tester) async {
    await tester.pumpWidget(const CoffeeLanApp());
    await tester.pump();

    expect(find.text('The COFFEE LAN'), findsOneWidget);
  });
}
