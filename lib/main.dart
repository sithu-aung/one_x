import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:one_x/core/constants/app_constants.dart';
import 'package:one_x/core/providers/theme_provider.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/auth/presentation/providers/auth_provider.dart';
import 'package:one_x/features/auth/presentation/screens/login_screen.dart';
import 'package:one_x/features/home/presentation/screens/home_screen.dart';
import 'package:one_x/core/utils/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'features/learning/presentation/screens/learning_page.dart';

// Global key for navigation
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const AppLoader());
}

// Initial app loader - pure Flutter, no Riverpod yet
class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  bool _isLoading = true;
  String? _savedTheme;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // First check authentication status directly
      final authToken = await SecureStorage.getAuthToken();

      // Then load theme preference
      final savedTheme = await SecureStorage.getTheme();

      // Update state with the initialization results
      if (mounted) {
        setState(() {
          _isAuthenticated = authToken != null;
          _savedTheme = savedTheme;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error during initialization: $e');
      // Even on error, transition to app
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while initializing
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    // After initialization, wrap the app with ProviderScope
    return ProviderScope(
      child: MainApp(
        initialTheme: _savedTheme,
        isAuthenticated: _isAuthenticated,
      ),
    );
  }
}

// Main app with Riverpod only after initialization is complete
class MainApp extends ConsumerStatefulWidget {
  final String? initialTheme;
  final bool isAuthenticated;

  const MainApp({super.key, this.initialTheme, required this.isAuthenticated});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  bool? _isLearning;
  bool _checkingLearning = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      // Set initial theme if available
      if (widget.initialTheme != null) {
        final themeType = _stringToThemeType(widget.initialTheme!);
        ref.read(themeProvider.notifier).setTheme(themeType);
      }
      // Set initial auth state
      if (widget.isAuthenticated) {
        ref.read(authProvider.notifier).setAuthenticated();
      } else {
        ref.read(authProvider.notifier).setUnauthenticated();
      }
      // Check is_learning flag
     // await _checkLearningFlag();
       await _checkIsLearning();
    });
  }

  // Bin Version
  Future<void> _checkLearningFlag() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.jsonbin.io/v3/b/681e1c4d8561e97a50109cdd'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final isLearning = data['record']?['is_learning'] == true;
        setState(() {
          _isLearning = isLearning;
          _checkingLearning = false;
        });
      } else {
        setState(() {
          _isLearning = false;
          _checkingLearning = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLearning = false;
        _checkingLearning = false;
      });
    }
  }

  Future<void> _checkIsLearning() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/flag-check'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final isLearning = data['data'] == true;
        setState(() {
          _isLearning = isLearning;
          _checkingLearning = false;
        });
      } else {
        setState(() {
          _isLearning = false;
          _checkingLearning = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLearning = false;
        _checkingLearning = false;
      });
    }
  }

  // Helper method to convert string to ThemeType
  ThemeType _stringToThemeType(String themeTypeString) {
    return ThemeType.values.firstWhere(
      (type) => type.toString() == 'ThemeType.$themeTypeString',
      orElse: () => ThemeType.whiteIndigo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final themeState = ref.watch(themeProvider);

    if (_checkingLearning) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }
    if (_isLearning != true) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const LearningPage(),
      );
    }

    return KeyedSubtree(
      key: ValueKey(themeState.restartKey),
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: false,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            navigatorKey: rootNavigatorKey,
            title: '1xKing App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            home: _buildHomeScreen(authState),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }

  Widget _buildHomeScreen(AuthStateData authState) {
    switch (authState.state) {
      case AuthState.authenticated:
        return const HomeScreen();
      case AuthState.unauthenticated:
      case AuthState.error:
        return const LoginScreen();
      case AuthState.initial:
      case AuthState.loading:
      default:
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          ),
        );
    }
  }
}
