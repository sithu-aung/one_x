import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/bet/data/repositories/bet_repository.dart';
import 'package:one_x/features/bet/domain/models/play_history_list_response.dart';
import 'package:one_x/features/bet/presentation/widgets/play_history_list_widget.dart';
import 'package:one_x/features/bet/presentation/providers/bet_providers.dart';
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

    return RefreshIndicator(
      onRefresh: () => ref.read(betHistoryProvider.notifier).fetchHistory(),
      child: Column(
        children: [
          //buildTimeFilterSection(),
          Expanded(child: buildHistoryContent(context, historyState)),
        ],
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

  Widget buildHistoryContent(BuildContext context, BetHistoryState state) {
    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            Text(
              'ကံစမ်းမှတ်တမ်း ရှာနေသည်...',
              style: TextStyle(color: AppTheme.textColor),
            ),
          ],
        ),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            Text(
              state.errorMessage!,
              style: TextStyle(color: AppTheme.textSecondaryColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Consumer(
              builder: (context, ref, child) {
                return ElevatedButton.icon(
                  onPressed: () {
                    // Manually trigger refresh using Riverpod
                    ref.read(betHistoryProvider.notifier).fetchHistory();
                  },
                  icon: Icon(Icons.refresh),
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
      );
    }

    final histories = state.histories;
    if (histories == null || histories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
      );
    }

    return PlayHistoryListWidget(histories: histories, isLoading: false);
  }
}
