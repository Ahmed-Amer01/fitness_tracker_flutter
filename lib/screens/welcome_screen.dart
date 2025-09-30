import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  PageController _pageController = PageController();
  int _currentIndex = 0;

  // Sample images - replace with your assets
  final List<String> _images = [
    'assets/images/image.png',
    'assets/images/image1.png',
    'assets/images/image2.jpg',
    'assets/images/image7.png',
  ];

  @override
  void initState() {
    super.initState();
    // Set auth screens mode (always light)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ThemeProvider>(context, listen: false).setAuthScreens(true);
      // Preload images for smoother transitions
      _preloadImages(context);
    });

    // Auto-slide every 4 seconds (slightly slower for mobile readability)
    Future.delayed(Duration(seconds: 4), _autoSlide);
  }

  // Preload images to improve performance
  void _preloadImages(BuildContext context) {
    for (var image in _images) {
      precacheImage(AssetImage(image), context);
    }
  }

  void _autoSlide() {
    if (mounted) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _images.length;
      });
      _pageController.animateToPage(
        _currentIndex,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      Future.delayed(Duration(seconds: 4), _autoSlide);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.beige,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo Section
                Image.asset(
                  'assets/images/fitnessLogo.png',
                  fit: BoxFit.contain,
                  width: screenWidth * 0.3,
                  height: screenWidth * 0.15,
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

                // Image Slider Section (take ~40% of screen height)
                SizedBox(
                  height: screenHeight * 0.4,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                        offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                            itemCount: _images.length,
                            itemBuilder: (context, index) {
                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  return _buildImage(index, constraints);
                                },
                              );
                            },
                          ),
                          // Dots Navigation
                          Positioned(
                            bottom: 12,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _images.length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: isSmallScreen ? 8 : 10,
                                  height: isSmallScreen ? 8 : 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentIndex == index
                                      ? AppColors.blue900
                                      : AppColors.gray400.withOpacity(0.6),
                                ),
                              ),
                            ),
                          ),
                        ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: isSmallScreen ? 24 : 32),

                // Get Started Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue900,
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 14 : 16,
                        horizontal: isSmallScreen ? 24 : 32,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      color: Colors.white,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: isSmallScreen ? 24 : 32),

                // About Us Section
                Column(
                  children: [
                  Text(
                    'About Us',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray800,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                    Text(
                      'Welcome to our fitness tracker app! 🚀\n\nWe help you stay on top of your workouts, track health stats, and achieve your goals while connecting with a supportive community.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                      color: AppColors.gray600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Image widget to display actual assets, flexible for any dimensions
  Widget _buildImage(int index, BoxConstraints constraints) {
    return Image.asset(
      _images[index],
      fit: BoxFit.contain,
      width: constraints.maxWidth,
      height: constraints.maxHeight,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          color: Colors.grey.shade300,
          child: Center(
            child: Text(
              'Image not found',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: constraints.maxWidth < 360 ? 16 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}