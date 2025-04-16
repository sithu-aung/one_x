import 'package:flutter/material.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/core/utils/api_service.dart';
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/features/bet/data/repositories/bet_repository.dart';
import 'dart:convert';

class ThreeDHolidaysWidget extends StatefulWidget {
  const ThreeDHolidaysWidget({super.key});

  @override
  State<ThreeDHolidaysWidget> createState() => _ThreeDHolidaysWidgetState();
}

class _ThreeDHolidaysWidgetState extends State<ThreeDHolidaysWidget> {
  // API data
  bool _isLoading = true;
  List<dynamic> _holidaysData = [];

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

    // Fetch holidays data
    fetchHolidaysData();
  }

  Future<void> fetchHolidaysData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use 3D holidays endpoint
      final data = await _betRepository.get3DHolidays();

      if (data is Map && data.containsKey('holidays')) {
        setState(() {
          _holidaysData = data['holidays'] as List<dynamic>;
          _isLoading = false;
        });
        print('3D Holidays Data: ${jsonEncode(_holidaysData)}');
      } else if (data is List) {
        setState(() {
          _holidaysData = data;
          _isLoading = false;
        });
        print('3D Holidays Data (List): ${jsonEncode(_holidaysData)}');
      } else {
        print('Unexpected data format: $data');
        setState(() {
          _holidaysData = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching 3D holidays: $e');
      setState(() {
        _isLoading = false;
      });

      // Show a snackbar with the error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load 3D holidays: $e'),
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: fetchHolidaysData,
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
      onRefresh: fetchHolidaysData,
      child: Container(
        color: AppTheme.backgroundColor,
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _holidaysData.isEmpty
                ? const Center(child: Text('No holiday data available'))
                : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _holidaysData.length,
                  itemBuilder: (context, index) {
                    final item = _holidaysData[index];
                    return buildHolidayCard(item);
                  },
                ),
      ),
    );
  }

  Widget buildHolidayCard(Map<String, dynamic> data) {
    // Extract values from holiday data
    final date = data['date'] ?? '';
    final description = data['description'] ?? 'Holiday';

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
