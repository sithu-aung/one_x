import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/bet/data/repositories/bet_repository.dart';
import 'package:one_x/features/bet/domain/models/play_history_list_response.dart';
import 'package:one_x/features/bet/presentation/widgets/play_history_list_widget.dart';
import 'package:one_x/features/bet/presentation/providers/bet_providers.dart';
import 'package:one_x/features/bet/presentation/screens/bet_slip_screen.dart';
import 'package:intl/intl.dart';

// State for the bet history
class BetHistoryState {
  final bool isLoading;
  final List<Histories>? histories;
  final String? errorMessage;

  BetHistoryState({this.isLoading = false, this.histories, this.errorMessage});

  BetHistoryState copyWith({
    bool? isLoading,
    List<Histories>? histories,
    String? errorMessage,
  }) {
    return BetHistoryState(
      isLoading: isLoading ?? this.isLoading,
      histories: histories ?? this.histories,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Provider for the bet history state
final betHistoryProvider =
    StateNotifierProvider<BetHistoryNotifier, BetHistoryState>((ref) {
      final repository = ref.watch(betRepositoryProvider);
      return BetHistoryNotifier(repository);
    });

// Notifier for the bet history state
class BetHistoryNotifier extends StateNotifier<BetHistoryState> {
  final BetRepository _repository;

  BetHistoryNotifier(this._repository)
    : super(BetHistoryState(isLoading: false, histories: [])) {
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    if (state.isLoading) return; // Prevent multiple simultaneous fetches

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Add a timeout to prevent indefinite loading
      final response = await _repository.get2DPlayHistory().timeout(
        const Duration(seconds: 15),
      );

      state = state.copyWith(isLoading: false, histories: response.histories);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load history: ${e.toString()}',
      );
    }
  }
}

class BetHistoryWidget extends ConsumerWidget {
  const BetHistoryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(betHistoryProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => ref.read(betHistoryProvider.notifier).fetchHistory(),
        child: _buildContent(context, historyState),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BetHistoryState state) {
    if (state.isLoading) {
      return _buildLoadingState();
    } else if (state.errorMessage != null) {
      return _buildErrorState(context, state.errorMessage!);
    } else if (state.histories == null || state.histories!.isEmpty) {
      return _buildEmptyState();
    } else {
      // Direct rendering of history items without nested ListView
      return _buildDirectHistoryList(context, state.histories!);
    }
  }

  Widget _buildLoadingState() {
    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        Container(height: 20),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 100),
              CircularProgressIndicator(color: AppTheme.primaryColor),
              const SizedBox(height: 16),
              Text(
                'ကံစမ်းမှတ်တမ်း ရှာနေသည်...',
                style: TextStyle(color: AppTheme.textColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        Container(height: 20),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 100),
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'အချက်အလက်များ ရယူရန် မအောင်မြင်ပါ',
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: AppTheme.textSecondaryColor),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton.icon(
                    onPressed: () {
                      ref.read(betHistoryProvider.notifier).fetchHistory();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('ပြန်လည်ကြိုးစားကြည့်ပါ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        Container(height: 20),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 100),
              Icon(
                Icons.history,
                color: AppTheme.textSecondaryColor.withOpacity(0.5),
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'ကံစမ်းမှတ်တမ်း မရှိသေးပါ',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Direct rendering of history items without using PlayHistoryListWidget
  Widget _buildDirectHistoryList(
    BuildContext context,
    List<Histories> histories,
  ) {
    // Determine if we're in a white/light theme
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    // Build the items directly in this widget
    final List<Widget> historyItems =
        histories
            .map((history) => _buildHistoryItem(context, history))
            .toList();

    // Add spacing to the end
    historyItems.add(const SizedBox(height: 100));

    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [Container(height: 12), ...historyItems],
    );
  }

  // Individual history item
  Widget _buildHistoryItem(BuildContext context, Histories history) {
    // Determine if we're in a white/light theme
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    // Get number of digits
    int digitCount = 0;
    if (history.lottery?.lotteryDigits != null) {
      digitCount = history.lottery!.lotteryDigits!.length;
    }

    // Format the date string
    String formattedDate = '';
    String formattedTime = '';
    if (history.date != null) {
      try {
        final DateTime dateTime = DateTime.parse(history.date!);
        formattedDate = DateFormat('E dd-MM-yyyy').format(dateTime);
        formattedTime = DateFormat('hh:mm a').format(dateTime);
      } catch (e) {
        formattedDate = history.date ?? '';
        formattedTime = '';
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BetSlipScreen(
                  invoiceId: history.id,
                  fromWinningRecords: true,
                ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isLightTheme ? Colors.white : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              isLightTheme
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
          border:
              isLightTheme
                  ? Border.all(color: Colors.grey.shade300, width: 1)
                  : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            history.invoiceNumber ?? 'N/A',
                            style: TextStyle(
                              color: AppTheme.textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${digitCount.toString()} ကွက်)',
                          style: TextStyle(
                            color: AppTheme.textColor,
                            fontSize: 14,
                            fontFamily: 'Pyidaungsu',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${history.amount ?? '0'} Ks',
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    history.user?.username ?? 'Unknown User',
                    style: TextStyle(color: Colors.purple, fontSize: 13),
                  ),
                  Text(
                    '$formattedDate | $formattedTime',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 12,
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

  Widget buildTimeFilterSection() {
    final now = DateTime.now();
    final formatter = DateFormat('dd-MM-yyyy');
    final today = formatter.format(now);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: 18,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            'ယနေ့အတွက် ($today)',
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
