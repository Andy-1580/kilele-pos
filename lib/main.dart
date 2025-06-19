import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_service.dart';
import 'services/backup_service.dart';
import 'providers/auth_provider.dart';
import 'providers/pos_provider.dart';
import 'providers/inventory_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  // Initialize local database
  await BackupService.instance.initDatabase();

  runApp(const KilelePOSApp());
}

class KilelePOSApp extends StatelessWidget {
  const KilelePOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => POSProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
      ],
      child: MaterialApp(
        title: 'Kilele POS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF1565C0),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1565C0),
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authProvider.user != null) {
          return const MainDashboard();
        }

        return const LoginScreen();
      },
    );
  }
}
