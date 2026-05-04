import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';

void main() async {
  // Global error handler to catch errors before runApp
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set error builder to show errors on screen instead of white void
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.red[900],
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 80),
              const SizedBox(height: 20),
              const Text(
                'CRITICAL APP ERROR',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                details.exception.toString(),
                style: const TextStyle(color: Colors.yellow, fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'STACK TRACE:',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                details.stack.toString(),
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  };

  try {
    // 1. Load .env
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint("Info: .env not found or empty (this is normal on Vercel)");
    }

    // 2. Initialize Supabase
    final supabaseUrl = const String.fromEnvironment('SUPABASE_URL').isNotEmpty 
        ? const String.fromEnvironment('SUPABASE_URL') 
        : (dotenv.env['SUPABASE_URL'] ?? '');
        
    final supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY').isNotEmpty 
        ? const String.fromEnvironment('SUPABASE_ANON_KEY') 
        : (dotenv.env['SUPABASE_ANON_KEY'] ?? '');

    if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    } else {
      debugPrint("Warning: Supabase credentials missing during init");
    }

    runApp(
      const ProviderScope(
        child: VentoApp(),
      ),
    );
  } catch (e, stack) {
    debugPrint("MAIN ERROR: $e");
    debugPrint(stack.toString());
    
    // Fallback app if everything else fails
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Initialization Failed:\n$e",
            style: const TextStyle(color: Colors.red, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ));
  }
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
