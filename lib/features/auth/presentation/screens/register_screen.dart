import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/auth/presentation/providers/auth_provider.dart';
import 'package:one_x/features/auth/presentation/screens/login_screen.dart';
import 'package:one_x/features/profile/presentation/screens/terms_condition_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _referralIdController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _agreedToTerms = false;
  String? _errorMessage;
  String _ageGroup = '18+';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralIdController.dispose();
    _dobController.dispose();

    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.darkGrayColor,
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppTheme.backgroundColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1950, 1, 1),
      lastDate: DateTime.now().subtract(
        const Duration(days: 365 * 18),
      ), // Must be 18+
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.cardColor,
              onSurface: AppTheme.textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Format date as yyyy-MM-dd for API
      final formattedDate =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        _dobController.text = formattedDate;
      });
    }
  }

  Future<void> _register() async {
    print('=== REGISTER SCREEN - _register() ===');

    // Validate form
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      print('Validation failed: empty fields');
      setState(() {
        _errorMessage = "Please fill all required fields";
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      print('Validation failed: password mismatch');
      setState(() {
        _errorMessage = "Passwords do not match";
      });
      return;
    }

    if (!_agreedToTerms) {
      print('Validation failed: terms not agreed');
      setState(() {
        _errorMessage = "Please agree to the terms and conditions";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Getting auth notifier...');
      final authNotifier = ref.read(authProvider.notifier);

      // Create a RegisterFormData object to bind form data
      final formData = RegisterFormData(
        nameController: _nameController,
        phoneController: _phoneController,
        passwordController: _passwordController,
        confirmPasswordController: _confirmPasswordController,
        referralController:
            _referralIdController.text.isEmpty ? null : _referralIdController,
        dateOfBirth:
            _dobController.text.isEmpty
                ? '1996-01-01'
                : _dobController.text, // Default date if not provided
        agreedToTerms: _agreedToTerms,
      );

      print('Form data created, calling register...');

      // Pass the form data to the register method and get the result
      final result = await authNotifier.register(formData);

      print('Register result: $result');

      if (result['success']) {
        // Registration successful - show success message and redirect to login
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Registration successful. Please login.'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );

          // Navigate to login screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } else {
        // Registration failed - show error message from the API
        final errorMessage = result['message'] ?? 'Registration failed';

        if (mounted) {
          // Get the ScaffoldMessengerState
          final scaffoldMessenger = ScaffoldMessenger.of(context);

          // Hide any existing SnackBars
          scaffoldMessenger.hideCurrentSnackBar();

          // Show the error in a SnackBar
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Unexpected errors that weren't caught by the provider
      print('Unexpected registration error: ${e.toString()}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred. Please try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
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

  // Add a new method for building text fields with a custom suffix widget
  Widget _buildTextFieldWithSuffix({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool readOnly = false,
    Widget? suffixWidget,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardExtraColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        style: TextStyle(color: AppTheme.textColor, fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 16,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: InputBorder.none,
          suffixIcon: suffixWidget,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 24),
              // Logo
              Image.asset(
                'assets/images/login_logo.png',
                height: 70,
                width: 200,
              ),
              const SizedBox(height: 30),

              // Card containing register form
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
                      side: BorderSide(color: Colors.grey.shade400, width: 1.0),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(0.3),
                    color: AppTheme.cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Register Customer Account heading
                          Center(
                            child: customText(
                              'Register Customer Account',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Name field
                          _buildTextField(
                            controller: _nameController,
                            hintText: 'အမည် ****',
                            keyboardType: TextInputType.name,
                          ),
                          const SizedBox(height: 20),

                          // Phone field
                          _buildTextField(
                            controller: _phoneController,
                            hintText: 'ဖုန်းနံပါတ် ****',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 20),

                          // Password field
                          _buildTextField(
                            controller: _passwordController,
                            hintText: 'လျှို့ဝှက်နံပါတ် အနည်းဆုံး ၈လုံး',
                            obscureText: _obscurePassword,
                            togglePasswordVisibility: _togglePasswordVisibility,
                            isPassword: true,
                          ),
                          const SizedBox(height: 20),

                          // Confirm Password field
                          _buildTextField(
                            controller: _confirmPasswordController,
                            hintText: 'လျှို့ဝှက်နံပါတ် အတည်ပြုပါ',
                            obscureText: _obscureConfirmPassword,
                            togglePasswordVisibility:
                                _toggleConfirmPasswordVisibility,
                            isPassword: true,
                          ),
                          const SizedBox(height: 20),

                          // Referral ID section
                          customText('မိတ်ဆက်ကုဒ်', fontSize: 14),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: _referralIdController,
                            hintText: 'မိတ်ဆက်ကုဒ်',
                            prefixIcon: Symbols.person,
                            iconColor: AppTheme.primaryColor,
                          ),
                          const SizedBox(height: 20),

                          // Age verification section
                          customText('သတ်မှတ်ချက်ပြည့်မှီပါသလား', fontSize: 14),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Radio(
                                value: '18+',
                                groupValue: _ageGroup,
                                onChanged: (value) {
                                  setState(() {
                                    _ageGroup = value.toString();
                                  });
                                },
                                activeColor: AppTheme.primaryColor,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              Flexible(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _ageGroup = '18+';
                                    });
                                  },
                                  child: customText(
                                    '18 နှစ်ပြည့်',
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Radio(
                                value: '-18',
                                groupValue: _ageGroup,
                                onChanged: (value) {
                                  setState(() {
                                    _ageGroup = value.toString();
                                  });
                                },
                                activeColor: AppTheme.primaryColor,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              Flexible(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _ageGroup = '-18';
                                    });
                                  },
                                  child: customText(
                                    '18 နှစ်အောက်',
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Date of birth field
                          customText('မွေးနေ့', fontSize: 14),
                          const SizedBox(height: 10),
                          _buildTextFieldWithSuffix(
                            controller: _dobController,
                            hintText: 'Date of Birth (YYYY-MM-DD)',
                            keyboardType: TextInputType.datetime,
                            readOnly: true,
                            onTap: _selectDateOfBirth,
                            suffixWidget: Icon(
                              Symbols.calendar_today,
                              size: 22,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Terms and conditions checkbox
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: _agreedToTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreedToTerms = value ?? false;
                                    });
                                  },
                                  activeColor: AppTheme.primaryColor,
                                  checkColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    setState(() {
                                      _agreedToTerms = !_agreedToTerms;
                                    });
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '1xKing ၏ ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppTheme.textColor,
                                            fontFamily: 'Pyidaungsu',
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'စည်းမျဉ်းနှင့် စည်းကမ်းများ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppTheme.primaryColor,
                                            fontFamily: 'Pyidaungsu',
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          recognizer:
                                              TapGestureRecognizer()
                                                ..onTap = () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                              const TermsConditionScreen(),
                                                    ),
                                                  );
                                                },
                                        ),
                                        TextSpan(
                                          text: 'ကို လက်ခံပါသည်',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppTheme.textColor,
                                            fontFamily: 'Pyidaungsu',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Register button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                disabledBackgroundColor: AppTheme.primaryColor
                                    .withOpacity(0.6),
                              ),
                              child:
                                  _isLoading
                                      ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : customText(
                                        'Register',
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                            ),
                          ),

                          // Error message
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: customText(
                                _errorMessage!,
                                fontSize: 14,
                                color: Colors.red,
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Login link at bottom of card with cardExtraColor
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
                          'အကောင့်ရှိပြီးသားလား? ',
                          fontSize: 13,
                          color:
                              AppTheme.backgroundColor == Colors.white
                                  ? Colors.black
                                  : Colors.white,
                        ),
                        TextButton(
                          onPressed: _navigateToLogin,
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.only(left: 4),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: customText(
                            'Login',
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool isPassword = false,
    bool readOnly = false,
    Function()? onTap,
    Function()? togglePasswordVisibility,
    IconData? prefixIcon,
    IconData? suffixIcon,
    Color? iconColor,
  }) {
    final bool isMyanmar = isMyanmarText(hintText);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      style:
          isMyanmar
              ? getMyanmarTextStyle(fontSize: 14)
              : getTextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: hintText,
        labelStyle:
            isMyanmar
                ? getMyanmarTextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                )
                : getTextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
        floatingLabelStyle:
            isMyanmar
                ? getMyanmarTextStyle(fontSize: 12, color: Colors.white70)
                : getTextStyle(fontSize: 12, color: Colors.white70),
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
          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        alignLabelWithHint: true,
        prefixIcon:
            prefixIcon != null
                ? Padding(
                  padding: const EdgeInsets.only(left: 15, right: 10),
                  child: Icon(
                    prefixIcon,
                    color: iconColor ?? Colors.grey,
                    size: 20,
                  ),
                )
                : null,
        suffixIcon:
            isPassword
                ? Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: IconButton(
                    icon: Icon(
                      obscureText ? Symbols.visibility : Symbols.visibility_off,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: togglePasswordVisibility,
                  ),
                )
                : suffixIcon != null
                ? Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Icon(
                    suffixIcon,
                    color: iconColor ?? Colors.grey,
                    size: 20,
                  ),
                )
                : null,
      ),
    );
  }
}
