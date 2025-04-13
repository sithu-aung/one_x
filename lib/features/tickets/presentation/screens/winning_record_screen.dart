import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:one_x/features/bet/presentation/screens/bet_slip_screen.dart';
import 'package:one_x/features/bet/presentation/screens/amount_entry_screen.dart';

class WinningRecordScreen extends ConsumerStatefulWidget {
  const WinningRecordScreen({super.key});

  @override
  ConsumerState<WinningRecordScreen> createState() =>
      _WinningRecordScreenState();
}

class _WinningRecordScreenState extends ConsumerState<WinningRecordScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedLotteryType = '2D ထွက်ဂဏန်း';
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, dynamic>> _pendingRecords = [
    {
      'number': '04',
      'ticket_no': 'Tk_No - 00001',
      'user_name': 'User Name',
      'date': '23.09.2024-10:00AM',
      'bet': '80/10',
      'amount': '2,000 ks',
      'winning_amount': '160,000 ks',
    },
    {
      'number': '04',
      'ticket_no': 'Tk_No - 00001',
      'user_name': 'User Name',
      'date': '23.09.2024-10:00AM',
      'bet': '80/10',
      'amount': '2,000 ks',
      'winning_amount': '160,000 ks',
    },
    {
      'number': '04',
      'ticket_no': 'Tk_No - 00001',
      'user_name': 'User Name',
      'date': '23.09.2024-10:00AM',
      'bet': '80/10',
      'amount': '2,000 ks',
      'winning_amount': '160,000 ks',
    },
    {
      'number': '04',
      'ticket_no': 'Tk_No - 00001',
      'user_name': 'User Name',
      'date': '23.09.2024-10:00AM',
      'bet': '80/10',
      'amount': '2,000 ks',
      'winning_amount': '160,000 ks',
    },
  ];

  final List<Map<String, dynamic>> _completedRecords = [
    {
      'number': '04',
      'ticket_no': 'Tk_No - 00001',
      'user_name': 'User Name',
      'date': '23.09.2024-10:00AM',
      'bet': '80/10',
      'amount': '2,000 ks',
      'winning_amount': '160,000 ks',
    },
    {
      'number': '04',
      'ticket_no': 'Tk_No - 00001',
      'user_name': 'User Name',
      'date': '23.09.2024-10:00AM',
      'bet': '80/10',
      'amount': '2,000 ks',
      'winning_amount': '160,000 ks',
    },
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
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
              onTap: (index) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Pending Tab (ရရန်ရှိ)
                _buildPendingTab(),

                // Completed Tab (ရရှိပြီး)
                _buildCompletedTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildDropdownFilter(),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _pendingRecords.length,
            itemBuilder: (context, index) {
              return _buildRecordItem(_pendingRecords[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(child: _buildDropdownFilter()),
              const SizedBox(width: 12),
              Expanded(child: _buildDatePicker()),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _completedRecords.length,
            itemBuilder: (context, index) {
              return _buildRecordItem(_completedRecords[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedLotteryType,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          style: TextStyle(color: AppTheme.textColor),
          dropdownColor: AppTheme.cardColor,
          items:
              ['2D ထွက်ဂဏန်း', '3D ထွက်ဂဏန်း'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedLotteryType = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        onTap: () => _showDatePicker(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Choose Date', style: TextStyle(color: AppTheme.textColor)),
            Icon(Icons.calendar_month, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.cardColor,
              onSurface: AppTheme.textColor,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppTheme.backgroundColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildRecordItem(Map<String, dynamic> record) {
    return Card(
      color: AppTheme.cardColor,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: InkWell(
        onTap: () {
          // Convert the record data to BetItem format
          final List<BetItem> betItems = [
            BetItem(
              number: record['number'],
              betType: record['bet'],
              amount: record['amount'].replaceAll(' ks', ''),
            ),
          ];

          // Extract the total amount from the amount
          final int totalAmount = int.parse(
            record['amount'].replaceAll(',', '').replaceAll(' ks', ''),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => BetSlipScreen(
                    betItems: betItems,
                    totalAmount: totalAmount,
                    userName: record['user_name'],
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Number
                  Text(
                    record['number'],
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Date
                  Text(
                    record['date'],
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Ticket number and user name
              Row(
                children: [
                  Text(
                    '${record['ticket_no']} ',
                    style: TextStyle(color: AppTheme.textColor, fontSize: 13),
                  ),
                  Text(
                    record['user_name'],
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Bet and winning amounts - top row
              Row(
                children: [
                  // Left side - Bet
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          'ဆုငွေ အဆ',
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          record['bet'],
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right side - Result
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'ဆုအမျိုးအစား',
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'တည့်',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Bet and winning amounts - bottom row
              Row(
                children: [
                  // Left side - Amount
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          'ထိုးငွေ',
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          record['amount'],
                          style: TextStyle(
                            color: AppTheme.textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right side - Prize money
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'ဆုငွေ',
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          record['winning_amount'],
                          style: TextStyle(
                            color: AppTheme.textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
}
