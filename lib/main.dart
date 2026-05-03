import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: Could not load .env file: $e");
  }

  String cleanEnvValue(String? value, String key) {
    if (value == null) return '';
    // If the value accidentally includes "KEY=" (common issue on some web environments)
    if (value.startsWith('$key=')) {
      return value.substring(key.length + 1);
    }
    return value;
  }

  final supabaseUrl = cleanEnvValue(
    dotenv.env['SUPABASE_URL'] ?? const String.fromEnvironment('SUPABASE_URL'), 
    'SUPABASE_URL'
  );
  final supabaseAnonKey = cleanEnvValue(
    dotenv.env['SUPABASE_ANON_KEY'] ?? const String.fromEnvironment('SUPABASE_ANON_KEY'), 
    'SUPABASE_ANON_KEY'
  );

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    debugPrint("CRITICAL ERROR: Supabase credentials missing from .env");
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: VentoApp(),
    ),
  );
}

class VentoApp extends StatelessWidget {
  const VentoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VENTÖ Inventory POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/dashboard': (context) => const MainShell(),
      },
    );
  }
}
