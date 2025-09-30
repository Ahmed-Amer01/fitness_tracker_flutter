import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/loading_overlay.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

      final result = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (result.success) {
        // Fetch user profile and set theme
        await authProvider.fetchUserProfile();
        if (authProvider.user != null) {
          themeProvider.setThemeFromProfile(authProvider.user!.theme);
        }
        
        // Set to non-auth screens mode
        themeProvider.setAuthScreens(false);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful! Redirecting...'),
            backgroundColor: Colors.green,
          ),
        );
        
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main_layout');
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Login failed'),
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

                          // Login Form Card
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
                                        // Icon and Welcome Text
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.blue900,
                                          ),
                                          child: const Icon(
                                            Icons.fitness_center,
                                            size: 40,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        
                                        const Text(
                                          'Welcome Back!',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryDark,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        
                                        const Text(
                                          'Sign in to continue your fitness journey',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.gray600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 24),

                                        // Email Field
                                        TextFormField(
                                          controller: _emailController,
                                          keyboardType: TextInputType.emailAddress,
                                          decoration: const InputDecoration(
                                            labelText: 'Email',
                                            prefixIcon: Icon(Icons.email, color: AppColors.gray400),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Email is required';
                                            }
                                        if (!RegExp(
                                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                            .hasMatch(value)) {
                                              return 'Invalid email format';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),

                                        // Password Field
                                        TextFormField(
                                          controller: _passwordController,
                                          obscureText: true,
                                          decoration: const InputDecoration(
                                            labelText: 'Password',
                                            prefixIcon: Icon(Icons.lock, color: AppColors.gray400),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Password is required';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 32),

                                        // Login Button
                                        ElevatedButton(
                                          onPressed: authProvider.isLoading ? null : _login,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.blue900,
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'Log In',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Sign Up Link
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Don't have an account? ",
                                              style: TextStyle(color: AppColors.gray600),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pushReplacementNamed(context, '/register');
                                              },
                                              child: Text(
                                                'Sign up',
                                                style: TextStyle(
                                                  color: AppColors.skyBrand,
                                                  fontWeight: FontWeight.w600,
                                                  decoration: TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),

                                        // Forgot Password Link
                                        Center(
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(context, '/reset-password');
                                            },
                                            child: Text(
                                              'Forgot Password?',
                                              style: TextStyle(
                                                color: AppColors.skyBrand,
                                                fontWeight: FontWeight.w500,
                                                decoration: TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Back to Welcome Button
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/');
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_back, color: AppColors.skyBrand),
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

              // Loading Overlay
              if (authProvider.isLoading)
                const LoadingOverlay(text: 'Logging In...'),
            ],
          );
        },
      ),
    );
  }
}