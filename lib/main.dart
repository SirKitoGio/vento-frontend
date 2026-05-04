import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env file only if it exists and is not empty.
  // In Vercel, we rely on --dart-define instead.
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Note: .env file not loaded or empty (this is normal on Vercel): $e");
  }

  // Priority: String.fromEnvironment (Build Time) > dotenv (Local File)
  String getEnv(String key) {
    final value = String.fromEnvironment(key);
    if (value.isNotEmpty) return value;
    return dotenv.env[key] ?? '';
  }

  final supabaseUrl = getEnv('SUPABASE_URL');
  final supabaseAnonKey = getEnv('SUPABASE_ANON_KEY');

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    } catch (e) {
      debugPrint("CRITICAL ERROR: Failed to initialize Supabase: $e");
    }
  } else {
    debugPrint("CRITICAL ERROR: Supabase credentials are missing.");
    debugPrint("Please ensure --dart-define=SUPABASE_URL=... is set in your Vercel build command.");
  }

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
