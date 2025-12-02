import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String productList = '/products';
  static const String productDetail = '/products/detail';
  static const String addProduct = '/products/add';
  static const String editProduct = '/products/edit';
  static const String profile = '/profile';
  static const String filters = '/filters';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
      // return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.login:
      // return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
      // return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.home:
      // return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.productList:
      // return MaterialPageRoute(builder: (_) => const ProductListScreen());
      case AppRoutes.productDetail:
      // final productId = settings.arguments as String;
      // return MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: productId));
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
