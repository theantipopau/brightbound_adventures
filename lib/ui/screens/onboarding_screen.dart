import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/index.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Interactive Page 6: selected hero
  String? _selectedHero;

  // Interactive Page 7: tap the challenge to tick it
  bool _challengeTapped = false;

  late AnimationController _heroEntranceCtrl;

  final List<_PageContent> _pages = const [
    _PageContent(
      emoji: '🌟',
      title: 'Welcome to BrightBound Adventures!',
      description:
          'Embark on an amazing learning journey through 7 magical worlds!',
    ),
    _PageContent(
      emoji: '🗺️',
      title: 'Explore the World Map',
      description:
          'Travel between zones to discover new activities and challenges!',
    ),
    _PageContent(
      emoji: '⭐',
      title: 'Earn XP & Level Up',
      description:
          'Complete activities to earn XP, level up, and unlock new worlds!',
    ),
    _PageContent(
      emoji: '🏆',
      title: 'Collect Achievements',
      description:
          'Unlock trophies, keep your daily streak alive, and earn bonus stars!',
    ),
    _PageContent(
      emoji: '🎨',
      title: 'Customise Your Character',
      description:
          'Create your avatar and unlock new outfits as you progress!',
    ),
    // Page 6 & 7 are rendered as interactive overrides below
    _PageContent(emoji: '', title: '', description: ''),
    _PageContent(emoji: '', title: '', description: ''),
  ];

  @override
  void initState() {
    super.initState();
    _heroEntranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _heroEntranceCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _heroEntranceCtrl.forward(from: 0);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _skipToEnd() => _finish();

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    // Mark that we should show the first-time world map overlay
    await prefs.setBool('showWorldMapTip', true);
    if (_selectedHero != null) {
      await prefs.setString('preferredCharacter', _selectedHero!);
    }
    widget.onComplete();
  }

  bool get _canAdvance {
    if (_currentPage == 5) return _selectedHero != null;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.secondary],
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
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                      _heroEntranceCtrl.forward(from: 0);
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    if (index == 5) return _buildHeroSelectPage();
                    if (index == 6) return _buildDailyChallengePage();
                    return _StaticOnboardingPage(page: _pages[index]);
                  },
                ),
              ),

              // Page indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Next/Get Started button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _canAdvance ? 1.0 : 0.4,
                  child: ElevatedButton(
                    onPressed: _canAdvance ? _nextPage : null,
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
                          ? 'Start Adventure! 🚀'
                          : (_currentPage == 5
                              ? (_selectedHero != null
                                  ? 'Great choice! Next →'
                                  : 'Choose your hero first')
                              : 'Next'),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildHeroSelectPage() {
    const heroes = [
      {'emoji': '🧙', 'label': 'Wizard'},
      {'emoji': '🦸', 'label': 'Hero'},
      {'emoji': '🧝', 'label': 'Elf'},
      {'emoji': '🐉', 'label': 'Dragon'},
      {'emoji': '🦊', 'label': 'Fox'},
      {'emoji': '🤖', 'label': 'Robot'},
    ];

    return FadeTransition(
      opacity: _heroEntranceCtrl,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎮',
                style: TextStyle(fontSize: 64)),
            const SizedBox(height: 20),
            const Text(
              'Choose Your Hero!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap one to pick your adventure character',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.85)),
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: heroes.map((h) {
                final id = h['label']!;
                final emoji = h['emoji']!;
                final selected = _selectedHero == id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedHero = id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.elasticOut,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? Colors.amber
                            : Colors.white.withValues(alpha: 0.4),
                        width: selected ? 3 : 1.5,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: Colors.amber.withValues(alpha: 0.6),
                                blurRadius: 16,
                                spreadRadius: 2,
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(emoji,
                            style: TextStyle(
                                fontSize: selected ? 44 : 36)),
                        const SizedBox(height: 4),
                        Text(
                          id,
                          style: TextStyle(
                            color:
                                selected ? AppColors.primary : Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChallengePage() {
    return FadeTransition(
      opacity: _heroEntranceCtrl,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎯',
                style: TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            const Text(
              'Complete Quests Every Day!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              'Your daily challenge appears right on the world map. '
              'Three challenges per day — easy, medium, and hard! '
              'Tap the badge below to see how it works:',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.88),
                  height: 1.5),
            ),
            const SizedBox(height: 32),
            // Interactive mock challenge card
            GestureDetector(
              onTap: () => setState(() => _challengeTapped = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticOut,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _challengeTapped
                      ? Colors.amber
                      : Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _challengeTapped
                        ? Colors.amber.shade700
                        : Colors.white.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  boxShadow: _challengeTapped
                      ? [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 4,
                          )
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    Text(
                      _challengeTapped ? '🏆' : '🎯',
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _challengeTapped
                                ? 'Challenge Complete!'
                                : 'Math Master',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _challengeTapped
                                  ? Colors.white
                                  : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _challengeTapped
                                ? '+50 XP earned! Great work!'
                                : 'Solve 5 maths problems  •  Tap to accept!',
                            style: TextStyle(
                              fontSize: 12,
                              color: _challengeTapped
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _challengeTapped
                          ? Icons.check_circle
                          : Icons.chevron_right,
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
            if (!_challengeTapped) ...[
              const SizedBox(height: 16),
              Text(
                '👆 Tap the card above!',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PageContent {
  final String emoji;
  final String title;
  final String description;
  const _PageContent(
      {required this.emoji, required this.title, required this.description});
}

class _StaticOnboardingPage extends StatelessWidget {
  final _PageContent page;
  const _StaticOnboardingPage({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(page.emoji, style: const TextStyle(fontSize: 110)),
          const SizedBox(height: 40),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2),
          ),
          const SizedBox(height: 20),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 17,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.5),
          ),
        ],
      ),
    );
  }
}

// Keep backward-compat alias used in tests / other references
class OnboardingPage extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.emoji,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return _StaticOnboardingPage(
      page: _PageContent(
          emoji: emoji, title: title, description: description),
    );
  }
}

