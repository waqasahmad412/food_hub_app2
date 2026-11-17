import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/cart_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/search_screen.dart';
import 'screens/add_post_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/main_shell.dart';
import 'screens/orders_screen.dart';
import 'utils/app_colors.dart';

Future<void> main() async {
  // Flutter bindings must be ready before touching platform channels.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using the generated platform configuration.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const FoodDashApp());
}

class FoodDashApp extends StatelessWidget {
  const FoodDashApp({super.key});

  @override
  Widget build(BuildContext context) {
    // CartProvider is scoped to the whole app so the Home badge, the
    // restaurant details screen and the cart screen all stay in sync.
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        title: 'FoodDash',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
          ).copyWith(primary: AppColors.primary),
          scaffoldBackgroundColor: AppColors.background,
        ),
        // The authentication flow is the entry point for now.
        home: const LoginScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const MainShell(),
          '/cart': (context) => const CartScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/orders': (context) => const OrdersScreen(),
          '/search': (context) => const SearchScreen(),
          '/addPost': (context) => const AddPostScreen(),
        },
      ),
    );
  }
}
