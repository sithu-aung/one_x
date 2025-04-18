import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/core/theme/app_theme.dart' as theme show ThemeType;
import 'package:one_x/core/providers/theme_provider.dart';
import 'package:one_x/features/auth/presentation/providers/auth_provider.dart';
import 'package:one_x/features/auth/presentation/screens/login_screen.dart';
import 'package:one_x/features/bet/presentation/screens/two_d_screen.dart';
import 'package:one_x/features/payment/presentation/screens/payment_page.dart';
import 'package:one_x/features/profile/presentation/screens/profile_screen.dart';
import 'package:one_x/features/profile/presentation/screens/terms_condition_screen.dart';
import 'package:one_x/features/profile/presentation/screens/privacy_policy_screen.dart';
import 'package:one_x/features/settings/presentation/screens/theme_selection_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:one_x/features/home/presentation/widgets/bottom_navigation.dart';
import 'package:one_x/features/tickets/presentation/screens/winning_record_screen.dart';
import 'package:one_x/features/home/presentation/providers/home_provider.dart';
import 'package:one_x/features/home/data/models/home_model.dart';
import 'package:one_x/features/notification/presentation/screens/notification_screen.dart';
import 'package:one_x/features/notification/presentation/providers/notification_provider.dart';
import 'package:one_x/features/bet/presentation/screens/three_d_screen.dart';
import 'package:one_x/features/payment/presentation/screens/top_up_page.dart';
import 'package:one_x/features/payment/presentation/screens/withdraw_amount_define_screen.dart';
import 'package:one_x/features/payment/presentation/screens/change_currency_page.dart';
import 'package:one_x/features/profile/presentation/screens/faq/faq_screen.dart';
import 'package:one_x/features/profile/presentation/screens/contact_us_screen.dart';
import 'package:one_x/features/lottery/presentation/screens/coming_soon_screen.dart';
import 'package:one_x/core/utils/secure_storage.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentPageIndex = 0;
  final PageController _pageController = PageController();
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    // Auto-scroll the banner every 3 seconds
    Future.delayed(const Duration(milliseconds: 500), () {
      _startAutoScroll();
      // Refresh home data when the screen initializes
      ref.refresh(homeDataProvider);
      // Initialize notifications
      ref.read(notificationProvider.notifier).fetchNotifications();
    });
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _pageController.hasClients) {
        int nextPage = (_currentPageIndex + 1) % 3;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      } else if (mounted) {
        // Try again if controller is not attached to any scroll view yet
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      extendBody: true,
      appBar: _buildAppBar(),
      drawer: Drawer(
        backgroundColor: AppTheme.cardColor,
        width: MediaQuery.of(context).size.width * 0.75,
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // User profile section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const ProfileScreen(fromHomeDrawer: true),
                          ),
                        );
                      },
                      child: Consumer(
                        builder: (context, ref, _) {
                          final user = ref.watch(homeUserProvider);
                          return CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                user?.profilePhoto != null
                                    ? NetworkImage(user!.profilePhoto)
                                    : const AssetImage(
                                          'assets/images/avatar.png',
                                        )
                                        as ImageProvider,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const ProfileScreen(fromHomeDrawer: true),
                          ),
                        );
                      },
                      child: Consumer(
                        builder: (context, ref, _) {
                          final user = ref.watch(homeUserProvider);
                          return Text(
                            user?.username ?? 'User Name',
                            style: TextStyle(
                              color: AppTheme.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Image.asset(
                        'assets/images/humberger.png',
                        width: 24,
                        height: 24,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.grey, height: 1, thickness: 0.2),

              const SizedBox(height: 12),
              // Main navigation items
              _buildDrawerItem(
                icon: 'assets/icons/home.svg',
                title: 'Home',
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              // Betting Site Informations section
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  top: 16.0,
                  bottom: 8.0,
                ),
                child: Text(
                  'Betting Site Informations',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
              _buildDrawerItem(
                icon: 'assets/icons/about.svg',
                title: 'FAQ',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FAQScreen()),
                  );
                },
              ),
              // _buildDrawerItem(
              //   icon: 'assets/icons/help.svg',
              //   title: 'How To Play',
              //   onTap: () {
              //     Navigator.pop(context);
              //   },
              // ),
              // _buildDrawerItem(
              //   icon: 'assets/icons/info.svg',
              //   title: 'Draw Informations',
              //   onTap: () {
              //     Navigator.pop(context);
              //   },
              // ),
              // _buildDrawerItem(
              //   icon: 'assets/icons/faq.svg',
              //   title: 'FAQ',
              //   onTap: () {
              //     Navigator.pop(context);
              //   },
              // ),
              _buildDrawerItem(
                icon: 'assets/icons/support.svg',
                title: 'ဆက်သွယ်ရန်',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContactUsScreen(),
                    ),
                  );
                },
              ),

              // Policy section
              const Padding(
                padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
                child: Text(
                  'Policy',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              _buildDrawerItem(
                icon: 'assets/icons/terms.svg',
                title: 'Terms & Conditions',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TermsConditionScreen(),
                    ),
                  );
                },
              ),
              _buildDrawerItem(
                icon: 'assets/icons/privacy.svg',
                title: 'Privacy Policy',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),

              // Themes section
              const Padding(
                padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
                child: Text(
                  'Themes',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              _buildDrawerItem(
                icon: 'assets/icons/dark_mode.svg',
                title: 'Dark Mode',
                trailing: Consumer(
                  builder: (context, ref, _) {
                    final themeState = ref.watch(themeProvider);
                    final isDarkMode =
                        themeState.currentTheme == theme.ThemeType.darkIndigo;

                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Switch(
                        value: isDarkMode,
                        activeColor: Colors.white,
                        inactiveThumbColor: Colors.white,
                        activeTrackColor: const Color(
                          0xFF7C4DFF,
                        ).withOpacity(0.5),
                        inactiveTrackColor: const Color(0xFF7C4DFF),
                        onChanged: (bool value) {
                          // No longer close the drawer
                          ref
                              .read(themeProvider.notifier)
                              .setTheme(
                                value
                                    ? theme.ThemeType.darkIndigo
                                    : theme.ThemeType.whiteIndigo,
                              );
                        },
                      ),
                    );
                  },
                ),
                onTap: () {},
              ),

              // Logout button under dark mode toggle
              _buildDrawerItem(
                icon: 'assets/icons/logout.svg',
                title: 'Logout',
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutConfirmation(context);
                },
              ),

              // Available Banks section
              const Padding(
                padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
                child: Text(
                  'Available Banks',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildBankLogo('assets/images/kbz_pay.png'),
                    const SizedBox(width: 12),
                    _buildBankLogo('assets/images/wave_money.png'),
                    const SizedBox(width: 12),
                    _buildBankLogo('assets/images/aya_bank.png'),
                    const SizedBox(width: 12),
                    _buildBankLogo('assets/images/aya_pay.png'),
                    const SizedBox(width: 12),
                    _buildBankLogo('assets/images/ok_dollar.png'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [_buildBankLogo('assets/images/cb_pay.png')],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      body: _buildBody(),

      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentNavIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return Container(
          margin: EdgeInsets.only(bottom: 130),
          child: _buildTicketsContent(),
        );
      case 2:
        return Container(
          margin: EdgeInsets.only(bottom: 120),
          child: _buildWalletContent(),
        );
      case 3:
        return Container(
          margin: EdgeInsets.only(bottom: 120),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildProfileContent(),
        );
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          _buildBanner(),

          const SizedBox(height: 24),

          // Types of Bet Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(color: Colors.grey, thickness: 0.5),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'TYPES OF BET',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey, thickness: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Grid of betting options
                Consumer(
                  builder: (context, ref, child) {
                    final gamesAsyncValue = ref.watch(homeDataProvider);

                    return gamesAsyncValue.when(
                      data: (homeData) {
                        final games = homeData.games;
                        if (games.isEmpty) {
                          return _buildEmptyGamesState();
                        }

                        return AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 500),
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 1.2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            children:
                                games.map((game) {
                                  final gameType = game.game.toLowerCase();
                                  final bool isActive = game.isActive();
                                  String imagePath;
                                  String title;
                                  String subtitle;

                                  // Map game type to image and title
                                  switch (gameType) {
                                    case '2d':
                                      imagePath = 'assets/images/2D.png';
                                      title = '2D';
                                      subtitle =
                                          isActive
                                              ? 'Myanmar 2D'
                                              : 'Coming Soon';
                                      break;
                                    case '3d':
                                      imagePath = 'assets/images/3D.png';
                                      title = '3D';
                                      subtitle =
                                          isActive
                                              ? 'Myanmar 3D'
                                              : 'Coming Soon';
                                      break;
                                    case 'scrath_off':
                                      imagePath =
                                          'assets/images/scratch_off.png';
                                      title = 'SCRATCH OFF';
                                      subtitle =
                                          isActive
                                              ? 'Scratch Off'
                                              : 'Coming Soon';
                                      break;
                                    case 'mega_million':
                                      imagePath =
                                          'assets/images/mega_millions.png';
                                      title = 'MEGA MILLIONS';
                                      subtitle =
                                          isActive
                                              ? 'Mega Millions'
                                              : 'Coming Soon';
                                      break;
                                    case 'power_ball':
                                      imagePath =
                                          'assets/images/power_ball.png';
                                      title = 'POWERBALL';
                                      subtitle =
                                          isActive
                                              ? 'Power Ball'
                                              : 'Coming Soon';
                                      break;
                                    case 'nyc_lotto':
                                      imagePath = 'assets/images/new_lotto.png';
                                      title = 'LOTTO';
                                      subtitle =
                                          isActive
                                              ? 'NYC Lotto'
                                              : 'Coming Soon';
                                      break;
                                    case 'football':
                                      imagePath = 'assets/images/football.png';
                                      title = 'FOOTBALL';
                                      subtitle =
                                          isActive ? 'Football' : 'Coming Soon';
                                      break;
                                    case 'cash_4life':
                                      imagePath = 'assets/images/cash4life.png';
                                      title = 'CASH 4 LIFE';
                                      subtitle =
                                          isActive
                                              ? 'Cash 4 Life'
                                              : 'Coming Soon';
                                      break;
                                    default:
                                      imagePath = 'assets/images/2D.png';
                                      title = gameType.toUpperCase();
                                      subtitle =
                                          isActive ? gameType : 'Coming Soon';
                                  }

                                  return _buildBetOption(
                                    icon: Image.asset(imagePath, height: 40),
                                    title: title,
                                    subtitle: subtitle,
                                    onTap: () {
                                      if (gameType == '2d') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => const TwoDScreen(),
                                          ),
                                        );
                                      } else if (gameType == '3d') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const ThreeDScreen(),
                                          ),
                                        );
                                      } else if (gameType == 'power_ball' ||
                                          gameType == 'mega_million') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => ComingSoonScreen(
                                                  title:
                                                      gameType == 'power_ball'
                                                          ? 'Power Ball'
                                                          : 'Mega Millions',
                                                ),
                                          ),
                                        );
                                      }
                                      // Add navigation for other active games as needed
                                    },
                                    isComingSoon: !isActive,
                                  );
                                }).toList(),
                          ),
                        );
                      },
                      loading: () => _buildLoadingGamesState(),
                      error:
                          (error, stackTrace) => _buildErrorGamesState(error),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyGamesState() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_esports,
              size: 48,
              color: AppTheme.textSecondaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No games available right now',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGamesState() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: List.generate(
        4,
        (index) => Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorGamesState(Object error) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Text(
          'Error loading games',
          style: TextStyle(color: AppTheme.textColor, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildQuickAccessButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(color: AppTheme.textColor, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: Consumer(
          builder: (context, ref, child) {
            // Watch banners from provider
            final bannersAsyncValue = ref.watch(homeDataProvider);

            return bannersAsyncValue.when(
              data: (homeData) {
                final banners = homeData.banners;
                if (banners.isEmpty) {
                  return _buildEmptyBannerState();
                }

                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Banner PageView with rounded corners
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPageIndex = index;
                          });
                        },
                        itemCount: banners.length,
                        itemBuilder: (context, index) {
                          final banner = banners[index];
                          final imageUrl = banner.getFullImageUrl();

                          return Stack(
                            children: [
                              // Banner image
                              Positioned.fill(
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: AppTheme.cardColor,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppTheme.primaryColor,
                                              ),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/banner2.png',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                              // Gradient overlay for better text visibility
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.4),
                                      ],
                                      stops: const [0.7, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    // Dot indicators
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          banners.length,
                          (index) => GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: index == _currentPageIndex ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color:
                                    index == _currentPageIndex
                                        ? AppTheme.primaryColor
                                        : Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => _buildLoadingBannerState(),
              error: (error, stackTrace) => _buildErrorBannerState(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyBannerState() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          'No banners available',
          style: TextStyle(color: AppTheme.textSecondaryColor),
        ),
      ),
    );
  }

  Widget _buildLoadingBannerState() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBannerState() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          'Failed to load banners',
          style: TextStyle(color: AppTheme.textColor),
        ),
      ),
    );
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildBetOption({
    required Widget icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isComingSoon = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppTheme.buttonGradientColors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
              spreadRadius: 1,
            ),
          ],
          border:
              AppTheme.backgroundColor == Colors.white
                  ? Border.all(color: Colors.grey.withOpacity(0.3), width: 0.5)
                  : null,
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color:
                    isComingSoon
                        ? AppTheme.primaryColor
                        : AppTheme.buttonTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style:
                  subtitle == 'Coming Soon'
                      ? TextStyle(
                        color: AppTheme.buttonSecondaryTextColor.withOpacity(
                          0.8,
                        ),
                        fontFamily: 'Pyidaungsu',
                        fontSize: 12,
                        letterSpacing: 0.3,
                        height: 1.4,
                        leadingDistribution: TextLeadingDistribution.even,
                      )
                      : TextStyle(
                        color: AppTheme.buttonSecondaryTextColor,
                        fontSize: 12,
                      ),
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder screens for other navigation items
  Widget _buildTicketsContent() {
    return const WinningRecordScreen();
  }

  Widget _buildWalletContent() {
    return PaymentPage();
  }

  Widget _buildProfileContent() {
    return const ProfileScreen(fromHomeDrawer: false);
  }

  Widget _buildDrawerItem({
    required String icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: SvgPicture.asset(
                icon,
                colorFilter: ColorFilter.mode(
                  AppTheme.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(color: AppTheme.textColor, fontSize: 14),
            ),
            if (trailing != null) trailing,
            if (trailing == null) const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildBankLogo(String imagePath) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(imagePath, fit: BoxFit.cover),
      ),
    );
  }

  AppBar _buildAppBar() {
    // Show Winning Record title when on the tickets tab
    if (_currentNavIndex == 1) {
      return AppBar(
        backgroundColor: AppTheme.backgroundColor,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Image.asset(
                  'assets/images/humberger.png',
                  width: 24,
                  height: 24,
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        title: Text(
          'Winning Record',
          style: TextStyle(
            color: AppTheme.textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/images/search.png',
              width: 24,
              height: 24,
              color: AppTheme.textColor,
            ),
            onPressed: () {},
          ),
        ],
      );
    }

    // Default AppBar for other tabs
    return AppBar(
      backgroundColor: AppTheme.backgroundColor,
      leading: Builder(
        builder:
            (context) => IconButton(
              icon: Image.asset(
                'assets/images/humberger.png',
                width: 24,
                height: 24,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
      ),
      title: SvgPicture.asset(
        _isDarkMode()
            ? 'assets/icons/home_logo_dark.svg'
            : 'assets/icons/home_logo_light.svg',
        height: 28,
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: Image.asset(
            'assets/images/search.png',
            width: 24,
            height: 24,
            color: AppTheme.primaryColor,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Image.asset(
                'assets/images/notification.png',
                width: 24,
                height: 24,
                color: AppTheme.primaryColor,
              ),
              // Badge indicator for unread notifications
              Consumer(
                builder: (context, ref, _) {
                  final unreadCount = ref.watch(
                    unreadNotificationCountProvider,
                  );
                  if (unreadCount <= 0) return const SizedBox.shrink();

                  return Positioned(
                    right: -5,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          onPressed: () {
            // Navigate to notification screen and fetch notifications
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            ).then((_) {
              // Refresh notification count when returning from notification screen
              ref.refresh(notificationProvider);
            });
          },
        ),
        // IconButton(
        //   icon: Image.asset(
        //     'assets/images/announcement.png',
        //     width: 24,
        //     height: 24,
        //   ),
        //   onPressed: () {},
        // ),
      ],
    );
  }

  // Logout confirmation dialog
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.cardColor,
            title: Text('Logout', style: TextStyle(color: AppTheme.textColor)),
            content: Text(
              'Are you sure you want to logout?',
              style: TextStyle(color: AppTheme.textColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppTheme.textSecondaryColor),
                ),
              ),
              TextButton(
                onPressed: () => _performLogout(context),
                child: Text('Logout', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  // Perform logout
  void _performLogout(BuildContext context) async {
    _logout();
  }

  void _logout() async {
    // await SecureStorage.clearAll();
    // ref.read(navIndexProvider.notifier).reset();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  // Helper method to determine if dark mode is active
  bool _isDarkMode() {
    final themeState = ref.read(themeProvider);
    return themeState.currentTheme == ThemeType.darkIndigo ||
        themeState.currentTheme == ThemeType.darkPurple ||
        themeState.currentTheme == ThemeType.darkGreen ||
        themeState.currentTheme == ThemeType.blackRed ||
        themeState.currentTheme == ThemeType.purpleGold;
  }
}
