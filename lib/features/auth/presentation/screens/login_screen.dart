import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/core/utils/api_service.dart';
import 'package:one_x/features/auth/presentation/providers/auth_provider.dart';
import 'package:one_x/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:one_x/features/auth/presentation/screens/register_screen.dart';
import 'package:one_x/features/home/presentation/screens/home_screen.dart';
import 'dart:developer' as developer;

// Global navigator key to access Navigator without context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with WidgetsBindingObserver {
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadRememberMeStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Track app lifecycle for debugging purposes
    developer.log('[LOGIN] App lifecycle state: $state', name: 'LoginScreen');
  }

  Future<void> _loadRememberMeStatus() async {
    final authNotifier = ref.read(authProvider.notifier);
    final rememberMeStatus = await authNotifier.getRememberMeStatus();

    final loginFormNotifier = ref.read(loginFormProvider.notifier);
    loginFormNotifier.setRememberMe(rememberMeStatus);
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  // Context-independent global error dialog
  static void showGlobalErrorDialog(String message) {
    developer.log(
      '[LOGIN] Showing global error via NavigatorKey: $message',
      name: 'LoginScreen',
    );
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _login() async {
    developer.log('[LOGIN] Login attempt started', name: 'LoginScreen');

    setState(() {
      _isLoading = true;
    });

    final loginForm = ref.read(loginFormProvider);
    final username = loginForm.usernameController.text.trim();
    final password = loginForm.passwordController.text.trim();
    final rememberMe = loginForm.rememberMe;

    developer.log(
      '[LOGIN] Username: $username, RememberMe: $rememberMe',
      name: 'LoginScreen',
    );

    // Simple validation
    if (username.isEmpty || password.isEmpty) {
      developer.log(
        '[LOGIN] Validation failed - empty fields',
        name: 'LoginScreen',
      );
      setState(() {
        _isLoading = false;
      });
      showGlobalErrorDialog('Username and password are required');
      return;
    }

    try {
      developer.log(
        '[LOGIN] Starting authentication process',
        name: 'LoginScreen',
      );
      final authNotifier = ref.read(authProvider.notifier);

      // Flag to track if we've shown an error dialog to avoid duplicates
      bool errorDialogShown = false;

      // Set up a listener for auth state changes
      final unsubscribe = ref.listenManual(authProvider, (previous, next) {
        developer.log(
          '[LOGIN] Auth state changed: ${previous?.state} -> ${next.state}',
          name: 'LoginScreen',
        );

        if (next.state == AuthState.authenticated) {
          developer.log(
            '[LOGIN] Authentication successful, navigating to home',
            name: 'LoginScreen',
          );
          // Navigate to home screen on authentication using the navigator key
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false, // Remove all routes below
          );
        } else if (next.state == AuthState.error && !errorDialogShown) {
          developer.log(
            '[LOGIN] Auth state error: ${next.errorMessage}',
            name: 'LoginScreen',
          );
          // Show error dialog on authentication error
          errorDialogShown = true;
          showGlobalErrorDialog(next.errorMessage ?? 'Invalid credentials');
        }
      });

      // Call login directly and get the result
      developer.log('[LOGIN] Calling login method', name: 'LoginScreen');
      final result = await authNotifier.login(username, password, rememberMe);
      developer.log('[LOGIN] Login result: $result', name: 'LoginScreen');

      // Always update loading state regardless of result
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // Check if login was successful
      if (!result['success'] && !errorDialogShown) {
        developer.log(
          '[LOGIN] Login failed with message: ${result['message']}',
          name: 'LoginScreen',
        );
        // Show error dialog
        showGlobalErrorDialog(result['message'] ?? 'Invalid credentials');
      } else {
        developer.log(
          '[LOGIN] Login result processed, dialog shown: $errorDialogShown',
          name: 'LoginScreen',
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        '[LOGIN] Exception during login: $e\n$stackTrace',
        name: 'LoginScreen',
      );

      // Always update loading state on error
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // Show error dialog
      showGlobalErrorDialog('Login failed: ${e.toString()}');
    }
  }

  void _forgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  void _register() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  // Helper function to determine if text is Myanmar
  bool isMyanmarText(String text) {
    // Myanmar Unicode range: U+1000 to U+109F
    final myanmarRegex = RegExp(r'[\u1000-\u109F]');
    return myanmarRegex.hasMatch(text);
  }

  // Text style helper based on language
  TextStyle getTextStyle({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? AppTheme.textColor,
      fontFamily: 'Roboto', // Default for English
    );
  }

  // Myanmar text style helper
  TextStyle getMyanmarTextStyle({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? AppTheme.textColor,
      fontFamily: 'Pyidaungsu', // Myanmar font
    );
  }

  // Custom text widget that automatically selects the right font
  Widget customText(
    String text, {
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    TextAlign? textAlign,
  }) {
    return Text(
      text,
      style:
          isMyanmarText(text)
              ? getMyanmarTextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: color,
              )
              : getTextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: color,
              ),
      textAlign: textAlign,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginForm = ref.watch(loginFormProvider);
    final screenSize = MediaQuery.of(context).size;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // Use the global navigator key
      home: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Padding(
          padding: EdgeInsets.only(
            top:
                Theme.of(context).platform == TargetPlatform.iOS
                    ? MediaQuery.of(context).padding.top
                    : 0,
            bottom:
                Theme.of(context).platform == TargetPlatform.iOS
                    ? MediaQuery.of(context).padding.bottom
                    : 0,
          ),
          child: Stack(
            children: [
              // Top right corner image
              // Positioned(
              //   top: 0,
              //   right: 0,
              //   child: Image.asset(
              //     'assets/images/rectangle_stripe.png',
              //     width: screenSize.width * 0.3,
              //   ),
              // ),

              // // Bottom left corner image
              // Positioned(
              //   bottom: 0,
              //   left: 0,
              //   child: Image.asset(
              //     'assets/images/rectangle_stripe.png',
              //     width: screenSize.width * 0.3,
              //   ),
              // ),

              // Main content
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: screenSize.height * 0.1),
                    // Logo
                    Image.asset(
                      'assets/images/login_logo.png',
                      height: 70,
                      width: 200,
                    ),
                    const SizedBox(height: 30),

                    // Card containing login form
                    Column(
                      children: [
                        Card(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(0),
                            ),
                            side: BorderSide(
                              color: Colors.grey.shade400,
                              width: 1.0,
                            ),
                          ),
                          elevation: 10,
                          shadowColor: Colors.black.withOpacity(0.3),
                          color: AppTheme.cardColor,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                // Login Account Text
                                customText(
                                  'Login Account',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                const SizedBox(height: 30),

                                // Username/Email field
                                TextFormField(
                                  controller: loginForm.usernameController,
                                  style: getTextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                    labelText: 'အီးမေးလ် or ဖုန်း***',
                                    labelStyle: getMyanmarTextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                    floatingLabelStyle: getMyanmarTextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                    filled: true,
                                    fillColor: AppTheme.darkGrayColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: AppTheme.primaryColor,
                                        width: 1,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                    alignLabelWithHint: true,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Password field
                                TextFormField(
                                  controller: loginForm.passwordController,
                                  obscureText: _obscurePassword,
                                  style: getTextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                    labelText: 'လျို့ဝှက်နံပါတ်***',
                                    labelStyle: getMyanmarTextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                    floatingLabelStyle: getMyanmarTextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                    filled: true,
                                    fillColor: AppTheme.darkGrayColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: AppTheme.primaryColor,
                                        width: 1,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                    alignLabelWithHint: true,
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Symbols.visibility
                                              : Symbols.visibility_off,
                                          color: AppTheme.textSecondaryColor,
                                          size: 20,
                                        ),
                                        onPressed: _togglePasswordVisibility,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Remember Me and Forgot Password row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Remember Me checkbox
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: Checkbox(
                                            value: loginForm.rememberMe,
                                            onChanged: (value) {
                                              if (value != null) {
                                                ref
                                                    .read(
                                                      loginFormProvider
                                                          .notifier,
                                                    )
                                                    .setRememberMe(value);
                                              }
                                            },
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            activeColor: AppTheme.primaryColor,
                                            checkColor: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        customText('Remember Me', fontSize: 14),
                                      ],
                                    ),

                                    // Forgot Password link
                                    // GestureDetector(
                                    //   onTap: _forgotPassword,
                                    //   child: customText(
                                    //     'Forget Password?',
                                    //     fontSize: 14,
                                    //     fontWeight: FontWeight.w500,
                                    //     color: AppTheme.accentColor,
                                    //   ),
                                    // ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Login button
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      disabledBackgroundColor: AppTheme
                                          .primaryColor
                                          .withOpacity(0.6),
                                    ),
                                    child:
                                        _isLoading
                                            ? SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : customText(
                                              'အကောင့်ဝင်ပါ',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Register link at bottom of card with cardExtraColor
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppTheme.cardExtraColor,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              customText(
                                '1xKing အကောင့် မရှိသေးဘူးလား?',
                                fontSize: 14,
                                color:
                                    AppTheme.backgroundColor == Colors.white
                                        ? Colors.black
                                        : Colors.white,
                              ),
                              TextButton(
                                onPressed: _register,
                                style: TextButton.styleFrom(
                                  minimumSize: Size.zero,
                                  padding: const EdgeInsets.only(left: 4),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: customText(
                                  'Register',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      AppTheme.backgroundColor == Colors.white
                                          ? Colors.black
                                          : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
