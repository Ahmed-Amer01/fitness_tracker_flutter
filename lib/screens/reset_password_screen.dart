import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/loading_overlay.dart';
import '../theme/app_theme.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _otpSent = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Set auth screens mode (always light)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<ThemeProvider>(context, listen: false).setAuthScreens(true);
      }
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.requestOtp(_emailController.text);

    if (result.success) {
      setState(() {
        _otpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'OTP sent to your email'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Failed to send OTP'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final result = await authProvider.resetPassword(
        email: _emailController.text,
        otp: _otpController.text,
        newPassword: _newPasswordController.text,
      );

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Password reset successful! Please log in with your new password.'),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Password reset failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.beige,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Logo Section
                          Image.asset(
                            'assets/images/fitnessLogo.png',
                            fit: BoxFit.contain,
                            width: screenWidth * 0.5,
                            height: screenWidth * 0.2,
                            color: Theme.of(context).appBarTheme.iconTheme?.color,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Error loading fitnessLogo.png: $error\n$stackTrace');
                              return Icon(
                                Icons.image_not_supported,
                                color: Theme.of(context).appBarTheme.iconTheme?.color,
                                size: screenWidth * 0.1,
                              );
                            },
                          ),
                          SizedBox(height: isSmallScreen ? 24 : 32),

                          // Reset Form Card
                          SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        // Icon and Header
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.blue900,
                                          ),
                                          child: const Icon(
                                            Icons.lock_reset,
                                            size: 40,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Reset Password',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryDark,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _otpSent
                                              ? 'Enter the OTP sent to your email and your new password'
                                              : 'Enter your email address to receive an OTP',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.gray600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 24),

                                        // Email
                                        TextFormField(
                                          controller: _emailController,
                                          keyboardType: TextInputType.emailAddress,
                                          enabled: !_otpSent,
                                          decoration: const InputDecoration(
                                            labelText: 'Email',
                                            prefixIcon: Icon(Icons.email, color: AppColors.gray400),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Email is required';
                                            }
                                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                                .hasMatch(value)) {
                                              return 'Invalid email format';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),

                                        // Request OTP Button (only show if OTP not sent)
                                        if (!_otpSent) ...[
                                          ElevatedButton(
                                            onPressed: authProvider.isLoading ? null : _requestOtp,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.blue900,
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text(
                                              'Request OTP',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                        ],

                                        // OTP Field (show after OTP is sent)
                                        if (_otpSent) ...[
                                          TextFormField(
                                            controller: _otpController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: 'OTP',
                                              prefixIcon: Icon(Icons.security, color: AppColors.gray400),
                                            ),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'OTP is required';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),

                                          // New Password
                                          TextFormField(
                                            controller: _newPasswordController,
                                            obscureText: true,
                                            decoration: const InputDecoration(
                                              labelText: 'New Password',
                                              prefixIcon: Icon(Icons.lock, color: AppColors.gray400),
                                            ),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'New password is required';
                                              }
                                              if (value.length < 6) {
                                                return 'Password must be at least 6 characters';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 24),

                                          // Reset Password Button
                                          ElevatedButton(
                                            onPressed: authProvider.isLoading ? null : _resetPassword,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.blue900,
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text(
                                              'Reset Password',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),

                                          // Resend OTP
                                          Center(
                                            child: GestureDetector(
                                              onTap: authProvider.isLoading
                                                  ? null
                                                  : () {
                                                      setState(() {
                                                        _otpSent = false;
                                                      });
                                                    },
                                              child: const Text(
                                                'Didn\'t receive OTP? Request again',
                                                style: TextStyle(
                                                  color: AppColors.skyBrand,
                                                  fontWeight: FontWeight.w500,
                                                  decoration: TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Back to Login
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_back, color: AppColors.skyBrand),
                                const SizedBox(width: 8),
                                Text(
                                  'Back to Login',
                                  style: TextStyle(
                                    color: AppColors.skyBrand,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Loading Overlay
              if (authProvider.isLoading)
                const LoadingOverlay(text: 'Processing...'),
            ],
          );
        },
      ),
    );
  }
}