import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:one_x/core/providers/theme_provider.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/auth/presentation/providers/auth_provider.dart';
import 'package:one_x/features/auth/presentation/screens/login_screen.dart';
import 'package:one_x/features/home/presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize services
    Future.delayed(Duration.zero, () {
      // Load saved theme
      ref.read(themeProvider.notifier).loadSavedTheme();

      // Check authentication status
      ref.read(authProvider.notifier).checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    // Watch the theme state to rebuild when theme changes (including restartKey)
    final themeState = ref.watch(themeProvider);

    // Rebuild the entire app when theme changes by using the restart key
    return KeyedSubtree(
      key: ValueKey(themeState.restartKey),
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            key: appKey, // Use global navigator key from theme provider
            title: 'BetMM App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            home: _buildHomeScreen(authState),
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
