import 'package:cybercafe_app_mobile/main.dart';
import 'package:cybercafe_app_mobile/services/auth_service.dart';
import 'package:cybercafe_app_mobile/services/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra la pantalla de inicio de sesión', (tester) async {
    final auth = AuthService(storage: InMemoryTokenStorage());

    await tester.pumpWidget(CoffeeLanApp(auth: auth));
    await tester.pumpAndSettle();

    expect(find.text('The COFFEE LAN'), findsOneWidget);
  });
}
