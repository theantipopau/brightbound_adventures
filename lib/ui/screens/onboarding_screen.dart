import 'package:flutter/material.dart';
import '../themes/index.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingPage> _pages = [
    const OnboardingPage(
      emoji: '🌟',
      title: 'Welcome to BrightBound Adventures!',
      description: 'Embark on an amazing learning journey through 5 magical worlds!',
    ),
    const OnboardingPage(
      emoji: '🗺️',
      title: 'Explore the World Map',
      description: 'Travel between zones to discover new activities and challenges!',
    ),
    const OnboardingPage(
      emoji: '⭐',
      title: 'Earn XP & Level Up',
      description: 'Complete activities to earn XP, level up, and unlock new zones!',
    ),
    const OnboardingPage(
      emoji: '🏆',
      title: 'Collect Achievements',
      description: 'Unlock trophies and complete daily challenges!',
    ),
    const OnboardingPage(
      emoji: '🎨',
      title: 'Customize Your Character',
      description: 'Create your avatar and unlock new outfits as you progress!',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  void _skipToEnd() {
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipToEnd,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _pages[index];
                  },
                ),
              ),
              
              // Page indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Next/Get Started button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Get Started!'
                        : 'Next',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;

  const OnboardingPage({
    Key? key,
    required this.emoji,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji
          Text(
            emoji,
            style: const TextStyle(fontSize: 120),
          ),
          
          const SizedBox(height: 48),
          
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
