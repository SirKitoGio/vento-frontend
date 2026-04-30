import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vento_frontend/main.dart';
import 'package:vento_frontend/screens/login_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  setUpAll(() async {
    dotenv.loadFromString(envString: 'API_BASE_URL=http://localhost:8080');
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: VentoApp(),
      ),
    );

    // Verify that we are on the login screen.
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
