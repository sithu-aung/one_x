import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/core/utils/api_service.dart';
import 'package:intl/intl.dart';
import 'package:one_x/features/bet/presentation/screens/bet_slip_screen.dart';
import 'package:one_x/features/tickets/data/repositories/ticket_repository.dart';
import 'package:one_x/features/tickets/domain/models/winning_record_list_response.dart';

// Repository provider
final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  final apiService = ApiService(storageService: StorageService());
  final storageService = StorageService();
  return TicketRepository(
    apiService: apiService,
    storageService: storageService,
  );
});

// Filter state providers
final lotteryTypeProvider = StateProvider<String>((ref) => '2D');
final dateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final today = DateTime.now();
  return DateTimeRange(start: today, end: today);
});

// Winning records provider that depends on filter state
final winningRecordProvider = FutureProvider<WinningRecordListResponse>((
  ref,
) async {
  // Watch the filter state providers to rebuild only when they change
  final type = ref.watch(lotteryTypeProvider);
  final dateRange = ref.watch(dateRangeProvider);

  final repository = ref.watch(ticketRepositoryProvider);
  return repository.getWinningRecords(
    type: type,
    startDate: dateRange.start,
    endDate: dateRange.end,
  );
});

class WinningRecordScreen extends ConsumerStatefulWidget {
  const WinningRecordScreen({super.key});

  @override
  ConsumerState<WinningRecordScreen> createState() =>
      _WinningRecordScreenState();
}

class _WinningRecordScreenState extends ConsumerState<WinningRecordScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onLotteryTypeChanged(String? newType) {
    if (newType != null) {
      ref.read(lotteryTypeProvider.notifier).state = newType;
    }
  }

  void _onDateRangeChanged(DateTimeRange? newRange) {
    if (newRange != null) {
      ref.read(dateRangeProvider.notifier).state = newRange;
    }
  }

  void _navigateToSlipDetail(WinningRecord record) {
    if (record.lotteryId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => BetSlipScreen(
                invoiceId: record.lotteryId,
                fromWinningRecords: true,
              ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invoice details not available'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppTheme.backgroundColor,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primaryColor,
                indicatorWeight: 3,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: Colors.grey,
                tabs: const [Tab(text: 'ရရန်ရှိ'), Tab(text: 'ရရှိပြီး')],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Pending Tab (ရရန်ရှိ) - always empty
                  _buildPendingTab(),
                  // Completed Tab (ရရှိပြီး) - fetch from API
                  _buildCompletedTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingTab() {
    return const Center(child: Text('မှတ်တမ်း မရှိသေးပါ။'));
  }

  Widget _buildCompletedTab() {
    // Read values to display them, but don't watch to avoid rebuilds
    final selectedLotteryType = ref.read(lotteryTypeProvider);
    final selectedDateRange = ref.read(dateRangeProvider);

    // Only watch the async value to avoid unnecessary API calls
    final winningRecordAsync = ref.watch(winningRecordProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0),
          child: _buildFilterSection(selectedLotteryType, selectedDateRange),
        ),
        Expanded(
          child: winningRecordAsync.when(
            data: (response) {
              final records = response.winningRecord ?? [];
              if (records.isEmpty) {
                return const Center(child: Text('မှတ်တမ်း မရှိပါ။'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 0,
                ),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  return _buildRecordItem(records[index]);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection(String selectedType, DateTimeRange dateRange) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Records',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildDropdownFilter(selectedType)),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: _buildDateRangePicker(dateRange)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(String selectedType) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedType,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          style: TextStyle(color: AppTheme.textColor),
          dropdownColor: AppTheme.cardColor,
          items:
              ['2D', '3D'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
          onChanged: _onLotteryTypeChanged,
        ),
      ),
    );
  }

  Widget _buildDateRangePicker(DateTimeRange dateRange) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return GestureDetector(
      onTap: () async {
        final picked = await showDateRangePicker(
          context: context,
          initialDateRange: dateRange,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            final isDarkMode =
                AppTheme.backgroundColor.computeLuminance() < 0.5;
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme:
                    isDarkMode
                        ? ColorScheme.dark(
                          primary: AppTheme.primaryColor,
                          onPrimary: Colors.white,
                          surface: AppTheme.cardColor,
                          onSurface: AppTheme.textColor,
                        )
                        : ColorScheme.light(
                          primary: AppTheme.primaryColor,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Colors.black87,
                        ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
                dialogTheme: DialogThemeData(
                  backgroundColor: AppTheme.cardColor,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          _onDateRangeChanged(picked);
        }
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${dateFormat.format(dateRange.start)} ~ ${dateFormat.format(dateRange.end)}',
                style: TextStyle(color: AppTheme.textColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.date_range, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem(WinningRecord record) {
    final formatter = NumberFormat('#,###');

    return InkWell(
      onTap: () => _navigateToSlipDetail(record),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${record.type ?? ""} - ${record.winnerNumber ?? ""}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      record.prize ?? "",
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'ထိုးငွေ: ',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    '${formatter.format(int.tryParse(record.amount ?? '0') ?? 0)} Ks',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'ဆုငွေ: ',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    '${formatter.format(int.tryParse(record.prizeAmount ?? '0') ?? 0)} Ks',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
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
                    'Date: ${record.createdAt != null ? DateFormat('yyyy-MM-dd').format(DateTime.parse(record.createdAt!)) : ""}',
                    style: TextStyle(
                      color: AppTheme.textColor.withOpacity(0.7),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
