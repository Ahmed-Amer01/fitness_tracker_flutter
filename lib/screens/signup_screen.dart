import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/loading_overlay.dart';
import '../theme/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  XFile? _profileImage;
  final ImagePicker _picker = ImagePicker();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image =
          await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (image != null) {
        setState(() {
          _profileImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to pick image: $e")),
        );
      }
    }
  }

  Future<void> _signup() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

      final result = await authProvider.signup(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        profilePicPath: _profileImage?.path,
      );

      if (result.success) {
        themeProvider.resetToLightTheme();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Signup successful! Redirecting...'),
              backgroundColor: Colors.green),
        );

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Signup failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildProfileImage() {
    if (_profileImage == null) {
      return Icon(Icons.camera_alt, 
                  size: 40, 
                  color: AppColors.primaryDark
                  );
    }

    if (kIsWeb) {
      // For web, use Image.network
      return ClipOval(
        child: Image.network(
          _profileImage!.path,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
        ),
      );
    } else {
      // For mobile, use Image.file
      return ClipOval(
        child: Image.file(
          File(_profileImage!.path),
          fit: BoxFit.cover,
          width: 100,
          height: 100,
        ),
      );
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          'Create Account',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryDark,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 24),
                                        Center(
                                          child: GestureDetector(
                                            onTap: _pickImage,
                                            child: Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.gray400
                                                    .withOpacity(0.3),
                                                border: Border.all(
                                                  color: AppColors.blue900,
                                                  width: 2,
                                                ),
                                              ),
                                              child: _buildProfileImage(),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Tap to add profile picture (optional)',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.gray600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 24),
                                        TextFormField(
                                          controller: _firstNameController,
                                          decoration: InputDecoration(
                                            labelText: 'First Name',
                                            prefixIcon: Icon(Icons.person,
                                                color: AppColors.gray400),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'First Name is required';
                                            }
                                            if (!RegExp(r'^[A-Za-z\s]+$')
                                                .hasMatch(value)) {
                                              return 'No numbers or symbols';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          controller: _lastNameController,
                                          decoration: InputDecoration(
                                            labelText: 'Last Name',
                                            prefixIcon: Icon(Icons.person,
                                                color: AppColors.gray400),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Last Name is required';
                                            }
                                            if (!RegExp(r'^[A-Za-z\s]+$')
                                                .hasMatch(value)) {
                                              return 'No numbers or symbols';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          controller: _emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                            labelText: 'Email',
                                            prefixIcon: Icon(Icons.email,
                                                color: AppColors.gray400),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Email is required';
                                            }
                                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                                .hasMatch(value)) {
                                              return 'Invalid email format';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          controller: _passwordController,
                                          obscureText: true,
                                          decoration: InputDecoration(
                                            labelText: 'Password',
                                            prefixIcon: Icon(Icons.lock,
                                                color: AppColors.gray400),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Password is required';
                                            }
                                            if (value.length < 6) {
                                              return 'Password must be at least 6 characters';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 32),
                                        ElevatedButton(
                                          onPressed: authProvider.isLoading
                                              ? null
                                              : _signup,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                              AppColors.blue900,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'Sign Up',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Already have an account? ',
                                              style: TextStyle(
                                                  color: AppColors.gray600),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pushReplacementNamed(
                                                    context, '/login');
                                              },
                                              child: Text(
                                                'Log in',
                                                style: TextStyle(
                                                  color: AppColors.skyBrand,
                                                  fontWeight: FontWeight.w600,
                                                  decoration: TextDecoration
                                                      .underline,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/');
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_back,
                                    color: AppColors.skyBrand),
                                const SizedBox(width: 8),
                                Text(
                                  'Back to Welcome',
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
              if (authProvider.isLoading)
                const LoadingOverlay(text: 'Signing Up...'),
            ],
          );
        },
      ),
    );
  }
}