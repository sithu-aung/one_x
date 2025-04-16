import 'package:flutter/material.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/core/utils/api_service.dart';
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/features/bet/data/repositories/bet_repository.dart';
import 'dart:convert';

class ThreeDHistoryNumbersWidget extends StatefulWidget {
  const ThreeDHistoryNumbersWidget({super.key});

  @override
  State<ThreeDHistoryNumbersWidget> createState() =>
      _ThreeDHistoryNumbersWidgetState();
}

class _ThreeDHistoryNumbersWidgetState
    extends State<ThreeDHistoryNumbersWidget> {
  // API data
  bool _isLoading = true;
  List<dynamic> _historyData = [];

  // Repository
  late BetRepository _betRepository;

  @override
  void initState() {
    super.initState();

    // Initialize repository directly
    final storageService = StorageService();
    final apiService = ApiService(storageService: storageService);
    _betRepository = BetRepository(
      apiService: apiService,
      storageService: storageService,
    );

    // Fetch history data
    fetchHistoryData();
  }

  Future<void> fetchHistoryData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use 3D history endpoint
      final data = await _betRepository.get3DHistory();

      if (data is Map && data.containsKey('results')) {
        setState(() {
          _historyData = data['results'] as List<dynamic>;
          _isLoading = false;
        });
        print('3D History Data: ${jsonEncode(_historyData)}');
      } else if (data is List) {
        setState(() {
          _historyData = data;
          _isLoading = false;
        });
        print('3D History Data (List): ${jsonEncode(_historyData)}');
      } else {
        print('Unexpected data format: $data');
        setState(() {
          _historyData = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching 3D history: $e');
      setState(() {
        _isLoading = false;
      });

      // Show a snackbar with the error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load 3D history: $e'),
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: fetchHistoryData,
              ),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchHistoryData,
      child: Container(
        color: AppTheme.backgroundColor,
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _historyData.isEmpty
                ? const Center(child: Text('No history data available'))
                : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _historyData.length,
                  itemBuilder: (context, index) {
                    final item = _historyData[index];
                    return buildHistoryCard(item);
                  },
                ),
      ),
    );
  }

  Widget buildHistoryCard(Map<String, dynamic> data) {
    // Extract values from history data
    final date = data['date'] ?? '';
    final threed = data['threed'] ?? '--';
    final set = data['set'] ?? '--';
    final value = data['value'] ?? '--';

    // Determine if we're in a white/light theme
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow:
            isLightTheme
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ]
                : null,
        border:
            isLightTheme
                ? Border.all(color: Colors.grey.shade300, width: 1)
                : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardExtraColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Text(
              date,
              style: TextStyle(
                color: AppTheme.textColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'SET',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        set,
                        style: TextStyle(
                          color: AppTheme.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'VALUE',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          color: AppTheme.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '3D',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        threed,
                        style: TextStyle(
                          color:
                              threed == '--'
                                  ? Colors.blue
                                  : AppTheme.backgroundColor == Colors.white
                                  ? const Color(
                                    0xFFFFD700,
                                  ).withRed(255).withGreen(215).withBlue(0)
                                  : AppTheme.primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
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
    );
  }
}
