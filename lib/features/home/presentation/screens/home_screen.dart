import 'package:flutter/material.dart';
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
import 'package:one_x/core/constants/app_constants.dart';
import 'package:one_x/shared/widgets/profile_avatar.dart';
import 'package:marquee/marquee.dart';
import 'dart:async';
import 'package:one_x/core/utils/global_event_bus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../main.dart' show rootNavigatorKey;

class HomeScreen extends ConsumerStatefulWidget {
  final int? initialTabIndex;

  const HomeScreen({super.key, this.initialTabIndex});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentPageIndex = 0;
  final PageController _pageController = PageController();
  int _currentNavIndex = 0;
  StreamSubscription? _unauthorizedSubscription;
  final bool _checkedVersion = false;

  @override
  void initState() {
    super.initState();
    // Set initial tab index if provided
    if (widget.initialTabIndex != null) {
      _currentNavIndex = widget.initialTabIndex!;
    }

    // Auto-scroll the banner every 3 seconds
    Future.delayed(const Duration(milliseconds: 500), () {
      _startAutoScroll();
      // Refresh home data when the screen initializes
      ref.refresh(homeDataProvider);
      // Initialize notifications
      ref.read(notificationProvider.notifier).fetchNotifications();
    });

    // Listen for unauthorized events
    _unauthorizedSubscription = GlobalEventBus.instance.stream.listen((event) {
      if (event.type == EventType.unauthorized && mounted) {
        // If we received an unauthorized event, log the user out
        _logout();
      }
    });

    // Version check
   // _checkAppVersionBin();

    _checkAppVersion();
  }

  Future<void> _checkAppVersion() async {
    // if (_checkedVersion) return;
    // _checkedVersion = true;
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/flag-check'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final serverVersion =
            data['version']?.toString() ?? AppConstants.appVersion;
        print('serverVersion: $serverVersion');
        final currentVersion = AppConstants.appVersion;
        if (_isVersionGreater(serverVersion, currentVersion)) {
          print('serverVersion: $serverVersion');
          print('currentVersion: $currentVersion');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showUpdateDialog(serverVersion);
          });
        }
      }
    } catch (e) {
      // Ignore version check errors
    }
  }

  Future<void> _checkAppVersionBin() async {
    // if (_checkedVersion) return;
    // _checkedVersion = true;
    try {
      final response = await http.get(
        Uri.parse('https://api.jsonbin.io/v3/b/681e1c4d8561e97a50109cdd'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final serverVersion =
            data['record']?['version']?.toString() ?? AppConstants.appVersion;
        print('serverVersion: $serverVersion');
        final currentVersion = AppConstants.appVersion;
        if (_isVersionGreater(serverVersion, currentVersion)) {
          print('serverVersion: $serverVersion');
          print('currentVersion: $currentVersion');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showUpdateDialog(serverVersion);
          });
        }
      }
    } catch (e) {
      // Ignore version check errors
    }
  }

  bool _isVersionGreater(String server, String current) {
    final serverParts = server.split('.').map(int.parse).toList();
    final currentParts = current.split('.').map(int.parse).toList();
    for (int i = 0; i < serverParts.length; i++) {
      if (i >= currentParts.length) return true;
      if (serverParts[i] > currentParts[i]) return true;
      if (serverParts[i] < currentParts[i]) return false;
    }
    return serverParts.length > currentParts.length;
  }

  void _showUpdateDialog(String newVersion) {
    showDialog(
      context: rootNavigatorKey.currentContext!,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.system_update, color: Colors.indigo, size: 28),
                SizedBox(width: 8),
                Text('Update Available'),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                'App Version အသစ် ($newVersion) ရယူရန် \'Update Now\' ကို နှိပ်ပါ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () async {
                    const url =
                        'https://play.google.com/store/apps/details?id=com.mm.one_x';
                    if (await canLaunch(url)) {
                      await launch(
                        url,
                        forceSafariVC: false,
                        forceWebView: false,
                      );
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.open_in_new, size: 24, color: Colors.green),
                      SizedBox(width: 6),
                      Text(
                        'Update Now',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
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
    _unauthorizedSubscription?.cancel();
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
                          return ProfileAvatar(
                            radius: 20,
                            useHomeUserData:
                                true, // Use cached home data for better performance
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const ProfileScreen(
                                      fromHomeDrawer: true,
                                    ),
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
                        Text(
                          'Version 1.2.3',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/menu.svg',
                        width: 28,
                        height: 28,
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
                          // Close drawer and set theme with slight delay to allow animations to complete
                          Navigator.pop(context);
                          Future.delayed(const Duration(milliseconds: 100), () {
                            ref
                                .read(themeProvider.notifier)
                                .setTheme(
                                  value
                                      ? theme.ThemeType.darkIndigo
                                      : theme.ThemeType.whiteIndigo,
                                );
                          });
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
                    // const SizedBox(width: 12),
                    // _buildBankLogo('assets/images/aya_bank.png'),
                    // const SizedBox(width: 12),
                    // _buildBankLogo('assets/images/aya_pay.png'),
                    // const SizedBox(width: 12),
                    // _buildBankLogo('assets/images/ok_dollar.png'),
                  ],
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 16.0,
              //     vertical: 8.0,
              //   ),
              //   child: Row(
              //     children: [_buildBankLogo('assets/images/cb_pay.png')],
              //   ),
              // ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      body: SafeArea(child: _buildBody()),

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
        return _buildTicketsContent();
      case 2:
        return _buildWalletContent();
      case 3:
        return _buildProfileContent();
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
    return Column(
      children: [
        // Banner Text Marquee - No horizontal padding
        Consumer(
          builder: (context, ref, child) {
            final homeDataAsyncValue = ref.watch(homeDataProvider);

            return homeDataAsyncValue.when(
              data: (homeData) {
                // Only show marquee if bannerText has description
                if (homeData.bannerText != null &&
                    homeData.bannerText!.description.isNotEmpty) {
                  return Container(
                    width: double.infinity,
                    height: 40, // Fixed height for the Marquee
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      borderRadius:
                          BorderRadius.zero, // Flat corners instead of rounded
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Marquee(
                      text: homeData.bannerText!.description,
                      style: TextStyle(
                        color: AppTheme.textColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      scrollAxis: Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      blankSpace: 40.0,
                      velocity: 50.0,
                      pauseAfterRound: const Duration(seconds: 1),
                      showFadingOnlyWhenScrolling: true,
                      fadingEdgeStartFraction: 0.1,
                      fadingEdgeEndFraction: 0.1,
                      startPadding: 10.0,
                      accelerationDuration: const Duration(seconds: 1),
                      accelerationCurve: Curves.linear,
                      decelerationDuration: const Duration(milliseconds: 500),
                      decelerationCurve: Curves.easeOut,
                    ),
                  );
                }
                return const SizedBox.shrink(); // No banner text available
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            );
          },
        ),

        // Banner Slider - With horizontal padding
        Padding(
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
                                        if (loadingProgress == null)
                                          return child;
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
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Image.asset(
                                          'assets/images/banner2.png',
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  ),
                                  // Gradient overlay for better text visibility
                                ],
                              );
                            },
                          ),
                        ),
                        // Indicator dots
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
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
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
        ),
      ],
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
        padding: const EdgeInsets.all(4.0),
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
                icon: SvgPicture.asset(
                  'assets/icons/menu.svg',
                  width: 28,
                  height: 28,
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
              icon: SvgPicture.asset(
                'assets/icons/menu.svg',
                width: 28,
                height: 28,
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
        // IconButton(
        //   icon: Image.asset(
        //     'assets/images/search.png',
        //     width: 24,
        //     height: 24,
        //     color: AppTheme.primaryColor,
        //   ),
        //   onPressed: () {},
        // ),
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
    try {
      // If called from dialog, close the dialog first
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Clear focus before navigating
      FocusManager.instance.primaryFocus?.unfocus();

      // Call the auth provider's logout method to properly clear all data
      await ref.read(authProvider.notifier).logout();

      // Use rootNavigator to ensure we're using the top-most navigator
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      // If we encounter an error during logout, ensure we still redirect to login
      print('Error during logout: $e');
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _logout() async {
    // When called from the global event bus (401 error), we don't want to show a confirmation dialog
    // Just call _performLogout with context
    _performLogout(context);
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
