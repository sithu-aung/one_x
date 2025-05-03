import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/bet/domain/models/play_history_list_response.dart';
import 'package:one_x/features/bet/presentation/widgets/play_history_list_widget.dart';
import 'package:one_x/features/bet/presentation/providers/bet_providers.dart';
import 'package:intl/intl.dart';

class ThreeDHistoryWidget extends ConsumerWidget {
  const ThreeDHistoryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(threeDHistoryProvider);

    return RefreshIndicator(
      onRefresh:
          () => ref.read(threeDHistoryProvider.notifier).getPlayHistory(),
      color: AppTheme.primaryColor,
      backgroundColor: Theme.of(context).cardColor,
      strokeWidth: 2.5,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody:
                historyState.hasValue &&
                historyState.value?.histories != null &&
                historyState.value!.histories!.isNotEmpty,
            child: buildHistoryContent(context, historyState),
          ),
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

  Widget buildHistoryContent(
    BuildContext context,
    AsyncValue<PlayHistoryListResponse> state,
  ) {
    return state.when(
      loading:
          () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.primaryColor),
                const SizedBox(height: 16),
                Text(
                  '3D ကံစမ်းမှတ်တမ်း ရှာနေသည်...',
                  style: TextStyle(color: AppTheme.textColor),
                ),
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
                Text(
                  'အချက်အလက်များ ရယူရန် မအောင်မြင်ပါ',
                  style: TextStyle(
                    color: AppTheme.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: TextStyle(color: AppTheme.textSecondaryColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Consumer(
                  builder: (context, ref, child) {
                    return ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(threeDHistoryProvider.notifier)
                            .getPlayHistory();
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
      data: (data) {
        final histories = data.histories;
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
                  '3D ကံစမ်းမှတ်တမ်း မရှိသေးပါ',
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
      },
    );
  }
}
