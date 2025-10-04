// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:food_admin_app/core/app_theme.dart';
import 'package:food_admin_app/products_page.dart';
import 'package:food_admin_app/service/auth_service.dart';
import 'admin_dashboard.dart';
import 'admin_login.dart';
import 'firebase_options.dart';
import 'order_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Delivery Admin',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const AuthWrapper(), // Use AuthWrapper instead of direct route
      routes: {
        '/admin/login': (context) => const AdminLoginScreen(),
        '/admin/mainDashboard': (context) => const MainAdminDashboard(),
        '/admin/products': (context) => const ProductsManagementScreen(),
        '/admin/orders': (context) => const OrdersManagementScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}


class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    final String? email = await AuthService.getSavedEmail();
    print('email $email');
    setState(() {
      _isLoggedIn = loggedIn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
              const SizedBox(height: 20),
              const Text('Loading...'),
            ],
          ),
        ),
      );
    }

    return _isLoggedIn ? const MainAdminDashboard() : const AdminLoginScreen();
  }
}