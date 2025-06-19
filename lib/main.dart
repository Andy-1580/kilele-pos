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
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/connectivity_provider.dart';
import 'widgets/sync_status_indicator.dart';
import 'providers/transaction_history_provider.dart';
import 'screens/help_screen.dart';
import 'providers/product_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/user_provider.dart';
import 'providers/customer_provider.dart';
import 'screens/product_list_screen.dart';
import 'screens/transaction_list_screen.dart';
import 'screens/user_list_screen.dart';
import 'screens/customer_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ??
        'https://jklzhhjfiojyuyfzbcyq.supabase.co',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ??
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImprbHpoaGpmaW9qeXV5ZnpiY3lxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAzNDIwNTAsImV4cCI6MjA2NTkxODA1MH0.XDGxnGgtHeh5z34cMhi-DxOtOe2sWonpJA68Ga-qGhc',
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
        ChangeNotifierProvider(create: (_) => PosProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => TransactionHistoryProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
      ],
      child: Stack(
        children: [
          MaterialApp(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            home: const AuthWrapper(),
            routes: {
              '/products': (_) => const ProductListScreen(),
              '/transactions': (_) => const TransactionListScreen(),
              '/users': (_) => const UserListScreen(),
              '/customers': (_) => const CustomerListScreen(),
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Consumer<ConnectivityProvider>(
              builder: (context, connectivity, child) {
                if (connectivity.isOnline) return const SizedBox.shrink();
                return Container(
                  width: double.infinity,
                  color: Colors.orange,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.cloud_off, color: Colors.white),
                      SizedBox(width: 8),
                      Text('You are offline. Some features are unavailable.',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
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
