import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/features/auth/presentation/providers/auth_provider.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;

  static Future<dynamic> navigateTo(String routeName,
      {Object? arguments}) async {
    return navigator?.pushNamed(routeName, arguments: arguments);
  }

  static Future<dynamic> navigateToReplacement(String routeName,
      {Object? arguments}) async {
    return navigator?.pushReplacementNamed(routeName, arguments: arguments);
  }

  static Future<dynamic> navigateToAndRemoveUntil(String routeName,
      {Object? arguments, bool Function(Route<dynamic>)? predicate}) async {
    return navigator?.pushNamedAndRemoveUntil(
        routeName, predicate ?? (Route<dynamic> route) => false,
        arguments: arguments);
  }

  static void goBack() {
    navigator?.pop();
  }

  static void goBackWithResult(dynamic result) {
    navigator?.pop(result);
  }

  static void navigateToLogin() {
    // Make sure the user is properly logged out via the auth provider
    try {
      // Find the ProviderContainer in the current context
      final context = navigatorKey.currentContext;
      if (context != null) {
        final container = ProviderScope.containerOf(context);
        final authNotifier = container.read(authProvider.notifier);

        // Ensure we properly log out before navigating
        authNotifier.logout();
      }
    } catch (e) {
      print('Error during automatic logout: $e');
      // Even if there's an error, still navigate to login
    }

    // Navigate to login page and remove all routes below it
    navigator?.pushNamedAndRemoveUntil('/login', (route) => false);
  }

  static void showSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 3),
    Color backgroundColor = Colors.red,
    Color textColor = Colors.white,
  }) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(color: textColor),
          ),
          duration: duration,
          backgroundColor: backgroundColor,
        ),
      );
    }
  }

  static void navigateToErrorPage({
    required String message,
    int? statusCode,
  }) {
    // Show error dialog since we might not have a dedicated error page
    final context = navigatorKey.currentContext;
    if (context != null) {
      // First attempt to show as SnackBar if it's a simple message
      if (message.isNotEmpty && !message.contains('\n')) {
        showSnackBar(message: message);
      } else {
        // For complex messages with newlines, show as dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error${statusCode != null ? ' ($statusCode)' : ''}'),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }
}
