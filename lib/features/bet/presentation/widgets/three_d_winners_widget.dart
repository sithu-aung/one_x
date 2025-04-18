import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/bet/domain/models/winner_list_response.dart';
import 'package:one_x/features/bet/presentation/providers/bet_providers.dart';
import 'package:intl/intl.dart';

class ThreeDWinnersWidget extends ConsumerStatefulWidget {
  const ThreeDWinnersWidget({super.key});

  @override
  ConsumerState<ThreeDWinnersWidget> createState() =>
      _ThreeDWinnersWidgetState();
}

class _ThreeDWinnersWidgetState extends ConsumerState<ThreeDWinnersWidget> {
  late DateTime selectedDate;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize date to either 1st or 16th of current month based on proximity to current day
    selectedDate = _getDefaultDate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      // Fetch 3D winners for the selected date - moved from initState to here
      _fetchWinnersByDate();
      _isInitialized = true;
    }
  }

  /// Determines the default date for API calling
  /// Returns either 1st or 16th of the current month based on proximity to the current date
  DateTime _getDefaultDate() {
    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month, 1);
    final sixteenthOfMonth = DateTime(now.year, now.month, 16);

    // If today is before 16th, use 1st, otherwise use 16th
    if (now.day < 16) {
      return firstOfMonth;
    } else {
      return sixteenthOfMonth;
    }
  }

  void _fetchWinnersByDate() {
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(threeDWinnersProvider.notifier).getWinnersByDate(formattedDate);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    // Create a list of allowed dates (only 1st and 16th)
    final currentYear = DateTime.now().year;
    final availableDates = <DateTime>[];

    // Add all 1st and 16th dates from 2023 to current year
    for (int year = 2023; year <= currentYear; year++) {
      for (int month = 1; month <= 12; month++) {
        // Don't allow future dates
        if (year == currentYear && month > DateTime.now().month) break;

        availableDates.add(DateTime(year, month, 1));
        availableDates.add(DateTime(year, month, 16));
      }
    }

    // Sort dates in descending order (newest first)
    availableDates.sort((a, b) => b.compareTo(a));

    // Only include dates up to today
    availableDates.removeWhere((date) => date.isAfter(DateTime.now()));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      selectableDayPredicate: (DateTime date) {
        // Only allow 1st or 16th of the month
        return date.day == 1 || date.day == 16;
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _fetchWinnersByDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the 3D winners provider
    final winnersData = ref.watch(threeDWinnersProvider);

    return Column(
      children: [
        // Date selector
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppTheme.textColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('yyyy-MM-dd').format(selectedDate),
                    style: TextStyle(color: AppTheme.textColor, fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, color: AppTheme.textColor),
                ],
              ),
            ),
          ),
        ),

        // Winners data
        Expanded(
          child: winnersData.when(
            loading:
                () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading winners...'),
                    ],
                  ),
                ),
            error:
                (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text('Failed to load winners: ${error.toString()}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchWinnersByDate,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
            data: (data) => _buildWinnersContent(data, context),
          ),
        ),
      ],
    );
  }

  Widget _buildWinnersContent(
    WinnerListResponse winnersData,
    BuildContext context,
  ) {
    // Determine if we're in a white/light theme
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    // Calculate screen width for positioning
    final screenWidth = MediaQuery.of(context).size.width;
    final podiumWidth = screenWidth - 32; // Account for horizontal padding
    final centerBlockWidth = podiumWidth * 0.3; // Width for center block
    final sideBlockWidth =
        podiumWidth * 0.33; // Wider blocks for 2nd and 3rd place

    // Check if top3Lists has data
    final hasTop3Data =
        winnersData.top3Lists != null && winnersData.top3Lists!.isNotEmpty;

    return RefreshIndicator(
      onRefresh: () async {
        _fetchWinnersByDate();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Only show Winners podium if there's data in top3Lists
            if (hasTop3Data)
              SizedBox(
                height: 280,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Podium base - 3D style with overlapping blocks
                      Positioned(
                        bottom: 0,
                        left: 10,
                        right: 10,
                        height: 80, // Explicitly set height for the base stack
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // 2nd place podium - left
                            Positioned(
                              bottom: 0,
                              left: 0,
                              child: Container(
                                width: sideBlockWidth,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(
                                        0xFF6c52c3,
                                      ), // Purple gradient start
                                      Color(0xFF5545a3), // Purple gradient end
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: const Offset(0, 5),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '2',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      shadows: const [
                                        Shadow(
                                          color: Colors.black38,
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // 1st place podium - middle (taller)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  width: centerBlockWidth,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(
                                          0xFF6c52c3,
                                        ), // Purple gradient start
                                        Color(
                                          0xFF5545a3,
                                        ), // Purple gradient end
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        offset: const Offset(0, 5),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '1',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 42,
                                        fontWeight: FontWeight.bold,
                                        shadows: const [
                                          Shadow(
                                            color: Colors.black38,
                                            offset: Offset(0, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // 3rd place podium - right
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: sideBlockWidth,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(
                                        0xFF6c52c3,
                                      ), // Purple gradient start
                                      Color(0xFF5545a3), // Purple gradient end
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: const Offset(0, 5),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '3',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      shadows: const [
                                        Shadow(
                                          color: Colors.black38,
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 2nd place winner - left
                      Positioned(
                        bottom: 50,
                        left: 5,
                        width: 115,
                        height: 140,
                        child: _buildWinnerCard(
                          rank: "2",
                          isLightTheme: isLightTheme,
                          winner:
                              winnersData.top3Lists!.length > 1
                                  ? winnersData.top3Lists![1]
                                  : null,
                        ),
                      ),

                      // 3rd place winner - right
                      Positioned(
                        bottom: 50,
                        right: 5,
                        width: 115,
                        height: 140,
                        child: _buildWinnerCard(
                          rank: "3",
                          isLightTheme: isLightTheme,
                          winner:
                              winnersData.top3Lists!.length > 2
                                  ? winnersData.top3Lists![2]
                                  : null,
                        ),
                      ),

                      // 1st place winner - middle (on top of others)
                      Positioned(
                        bottom: 80,
                        left: 0,
                        right: 0,
                        height: 150,
                        child: Center(
                          child: SizedBox(
                            width: 125,
                            height: 150,
                            child: _buildWinnerCard(
                              rank: "1",
                              isLightTheme: isLightTheme,
                              winner: winnersData.top3Lists![0],
                              isFirstPlace: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // List of winners
            if (winnersData.winners == null || winnersData.winners!.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: Text('No winners data available')),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                itemCount: winnersData.winners!.length,
                itemBuilder: (context, index) {
                  final winner = winnersData.winners![index];
                  return _buildWinnerListItem(
                    isLightTheme: isLightTheme,
                    winner: winner,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinnerCard({
    required String rank,
    required bool isLightTheme,
    UserListItem? winner,
    bool isFirstPlace = false,
  }) {
    return Container(
      width: isFirstPlace ? 125 : 115,
      height: isFirstPlace ? 150 : 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8A60FF), // New purple gradient start
            Color(0xFF3D2388), // New purple gradient end
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white,
          width: isFirstPlace ? 3.0 : 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            offset: const Offset(0, 0),
            blurRadius: isFirstPlace ? 8 : 5,
            spreadRadius: isFirstPlace ? 2 : 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glowing effect overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: RadialGradient(
                  colors: [Colors.white.withOpacity(0.3), Colors.transparent],
                  center: Alignment.topLeft,
                  radius: 1.5,
                ),
              ),
            ),
          ),

          // Star with rank number at top
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Center(
                child: Image.asset(
                  rank == '1'
                      ? 'assets/images/ic_first.png'
                      : rank == '2'
                      ? 'assets/images/ic_second.png'
                      : 'assets/images/ic_third.png',
                  width: 42,
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 48, 10, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Name
                Text(
                  winner?.user?.username ?? '-',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isFirstPlace ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(0, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Description - using winner number and prize amount
                Text(
                  winner?.winnerNumber != null && winner?.prizeAmount != null
                      ? 'Won ${winner!.prizeAmount} Ks on ${winner.winnerNumber}'
                      : 'Lorem ipsum dolor sit amet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isFirstPlace ? 12 : 10,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerListItem({
    required bool isLightTheme,
    required UserListItem winner,
  }) {
    // Format date if available
    String formattedDate = '';
    if (winner.createdAt != null) {
      try {
        final datetime = DateTime.parse(winner.createdAt!);
        formattedDate = DateFormat('E dd-MM-yyyy | hh:mm a').format(datetime);
      } catch (e) {
        formattedDate = winner.createdAt ?? '';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isLightTheme ? Colors.white : const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
        border:
            isLightTheme
                ? Border.all(color: Colors.grey.shade300, width: 1)
                : null,
        boxShadow:
            isLightTheme
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ]
                : null,
      ),
      child: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
            child: Row(
              children: [
                // Avatar/Profile Image
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey.shade600,
                  child: Icon(
                    Icons.person,
                    color: Colors.grey.shade300,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),

                // User details
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // User name
                      Text(
                        winner.user?.username ?? 'Nyein Nyein',
                        style: TextStyle(
                          color:
                              isLightTheme ? AppTheme.textColor : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // User ID
                      Text(
                        winner.user?.hiddenPhone ?? '09xxxxxxx123',
                        style: TextStyle(
                          color:
                              isLightTheme
                                  ? AppTheme.textSecondaryColor
                                  : Colors.grey.shade400,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bet details
                Expanded(
                  flex: 8,
                  child: Row(
                    children: [
                      // Bet number column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ပေါက်ဂဏန်း',
                              style: TextStyle(
                                color:
                                    isLightTheme
                                        ? AppTheme.textSecondaryColor
                                        : Colors.grey.shade400,
                                fontSize: 10,
                                fontFamily: 'Pyidaungsu',
                              ),
                            ),
                            Text(
                              winner.winnerNumber ?? '-',
                              style: TextStyle(
                                color:
                                    isLightTheme
                                        ? AppTheme.textColor
                                        : Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),

                      // Bet amount column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ထိုးငွေ',
                              style: TextStyle(
                                color:
                                    isLightTheme
                                        ? AppTheme.textSecondaryColor
                                        : Colors.grey.shade400,
                                fontSize: 10,
                                fontFamily: 'Pyidaungsu',
                              ),
                            ),
                            Text(
                              winner.amount != null
                                  ? '${winner.amount} Ks'
                                  : '-',
                              style: TextStyle(
                                color:
                                    isLightTheme
                                        ? AppTheme.textColor
                                        : Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Win amount column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ဆုငွေ',
                              style: TextStyle(
                                color:
                                    isLightTheme
                                        ? AppTheme.textSecondaryColor
                                        : Colors.grey.shade400,
                                fontSize: 10,
                                fontFamily: 'Pyidaungsu',
                              ),
                            ),
                            Text(
                              winner.prizeAmount != null
                                  ? '${winner.prizeAmount} Ks'
                                  : '-',
                              style: TextStyle(
                                color:
                                    isLightTheme
                                        ? AppTheme.textColor
                                        : Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Date text positioned at top right
          Positioned(
            top: 6,
            right: 12,
            child: Text(
              formattedDate,
              style: TextStyle(
                color:
                    isLightTheme
                        ? AppTheme.textSecondaryColor
                        : Colors.grey.shade500,
                fontSize: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
