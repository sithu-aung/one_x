import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/auth/presentation/screens/new_password_screen.dart';
import 'package:one_x/features/auth/presentation/screens/register_screen.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isLoading = false;
  String? _errorMessage;
  int _timerSeconds = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _canResend = false;
    _timerSeconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  String _getOtpCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  void _resendCode() {
    if (_canResend) {
      // TODO: Implement resend code API call
      _startTimer();

      // Clear all OTP fields
      for (var controller in _controllers) {
        controller.clear();
      }

      // Set focus to first field
      _focusNodes.first.requestFocus();
    }
  }

  Future<void> _verifyCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final otpCode = _getOtpCode();

    // Simple validation
    if (otpCode.length != 4) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please enter the 4-digit verification code';
      });
      return;
    }

    try {
      // TODO: Implement verification API call

      // For now, just navigate to new password screen
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const NewPasswordScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
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

              // Card containing verification form
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
                        children: [
                          // Verification Text
                          customText(
                            'Verification',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(height: 20),

                          // Verification instruction
                          customText(
                            'သင့်ဖုန်းလ် or နံပါတ်ထိပေးပို့ထားသော ကုဒ်ကိုဖြည့်ပါ',
                            fontSize: 14,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          // OTP input row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              4,
                              (index) => SizedBox(
                                width: 60,
                                height: 60,
                                child: TextFormField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: getTextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: InputDecoration(
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
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(1),
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (value) {
                                    if (value.isNotEmpty && index < 3) {
                                      _focusNodes[index + 1].requestFocus();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Resend code option
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              customText(
                                'ကုဒ်ပြန်ပေးပို့ရန်',
                                fontSize: 14,
                                color: AppTheme.textSecondaryColor,
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: _canResend ? _resendCode : null,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: customText(
                                  _canResend
                                      ? '[အလုပ်မလုပ်]'
                                      : '[${_timerSeconds}s]',
                                  fontSize: 14,
                                  color:
                                      _canResend
                                          ? AppTheme.accentColor
                                          : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),

                          // Verify button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _verifyCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
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
                                        'အတည်ပြုပါ',
                                        fontSize: 16,
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
                          'BetMM အကောင့် မရှိသေးဘူးလား?',
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
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
            ],
          ),
        ),
      ),
    );
  }
}
