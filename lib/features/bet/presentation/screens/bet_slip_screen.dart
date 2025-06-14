import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/bet/presentation/screens/amount_entry_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:one_x/features/bet/data/repositories/bet_repository.dart';
import 'package:one_x/features/bet/presentation/providers/bet_provider.dart';
import 'package:one_x/features/home/presentation/providers/home_provider.dart';
import 'package:one_x/features/home/presentation/screens/home_screen.dart';

class BetSlipScreen extends ConsumerStatefulWidget {
  final List<BetItem>? betItems;
  final int? totalAmount;
  final String? userName;
  final int? invoiceId;
  final Map<String, dynamic>? invoiceData;
  final bool fromWinningRecords;
  final bool fromSuccessfulApiResponse;

  const BetSlipScreen({
    super.key,
    this.betItems,
    this.totalAmount,
    this.userName,
    this.invoiceId,
    this.invoiceData,
    this.fromWinningRecords = false,
    this.fromSuccessfulApiResponse = false,
  });

  @override
  ConsumerState<BetSlipScreen> createState() => _BetSlipScreenState();
}

class _BetSlipScreenState extends ConsumerState<BetSlipScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final GlobalKey _ticketKey = GlobalKey();
  bool _isSaving = false;
  bool _isLoading = false;

  // Slip data from API
  Map<String, dynamic> _slipData = {};
  List<dynamic> _lotteryDigits = [];
  String _invoiceNumber = '';
  String _userName = '';
  String _date = '';
  int _totalAmount = 0;
  String _status = '';

  @override
  void initState() {
    super.initState();

    // Refresh home data to update user balance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.refresh(homeDataProvider);
    });

    // If invoice ID is provided, fetch slip details
    if (widget.invoiceId != null) {
      _fetchSlipDetails(widget.invoiceId!);
    }
    // If invoice data is provided directly, process it
    else if (widget.invoiceData != null) {
      _processInvoiceData(widget.invoiceData!);
    }
  }

  Future<void> _fetchSlipDetails(int invoiceId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(betRepositoryProvider);
      final response = await repository.getSlipDetails(invoiceId);

      if (response.containsKey('error') && response['error'] == true) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response['message']}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        _processSlipData(response);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching slip details: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _processInvoiceData(Map<String, dynamic> invoiceData) {
    // Process basic invoice data and fetch full details
    setState(() {
      _invoiceNumber = invoiceData['invoice_number'] ?? '';
      _totalAmount = int.tryParse(invoiceData['amount'].toString()) ?? 0;

      if (invoiceData['id'] != null) {
        _fetchSlipDetails(invoiceData['id']);
      }
    });
  }

  void _processSlipData(Map<String, dynamic> data) {
    if (data.containsKey('invoice')) {
      final invoice = data['invoice'];
      final lottery = invoice['lottery'];

      setState(() {
        _slipData = data;
        _invoiceNumber = invoice['invoice_number'] ?? '';
        _userName = invoice['user']?['username'] ?? widget.userName ?? '';
        _date = invoice['date'] ?? '';
        _totalAmount =
            int.tryParse(lottery['total_amount'].toString()) ??
            widget.totalAmount ??
            0;
        _status = lottery['status'] ?? 'pending';

        // Process lottery digits
        if (lottery.containsKey('lottery_digits') &&
            lottery['lottery_digits'] is List) {
          _lotteryDigits = lottery['lottery_digits'];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'လက်မှတ် အသေးစိတ်',
          style: TextStyle(color: AppTheme.textColor),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.edit, color: Colors.blue),
        //     onPressed: () {
        //       // Return to the amount entry screen to edit bets
        //       Navigator.pop(context);
        //     },
        //   ),
        // ],
      ),
      // Bottom navigation bar with bottom padding for iOS
      bottomNavigationBar: _buildBottomButtons(context),
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Builder(
                  builder: (context) {
                    final bool isIOS =
                        Theme.of(context).platform == TargetPlatform.iOS;
                    return Column(
                      children: [
                        // Success message - only show if coming from successful API response
                        if (widget.fromSuccessfulApiResponse)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4CAF50),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Ticket Create Successfully!',
                                  style: TextStyle(
                                    color: Color(0xFF4CAF50),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Ticket with a little top padding
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 10.0,
                                left: 16.0,
                                right: 16.0,
                              ),
                              child: Screenshot(
                                controller: _screenshotController,
                                child: _buildTicket(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
      ),
    );
  }

  Widget _buildTicket(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zigzag top edge
          CustomPaint(
            painter: ZigzagPainter(isTop: true),
            size: const Size(double.infinity, 10),
          ),

          // Main content with white background
          Container(
            width: double.infinity,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 6),
                  _buildDottedDivider(),
                  const SizedBox(height: 12),
                  _buildTicketHeader(),
                  const SizedBox(height: 8),
                  _buildBetDetails(),
                  const SizedBox(height: 8),
                  _buildDottedDivider(),
                  _buildBetItemsHeader(),
                  ..._buildBetItemsList(),
                  _buildDottedDivider(),
                  _buildTotalRow(),
                  _buildDottedDivider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'Thank You!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  _buildDottedDivider(),
                ],
              ),
            ),
          ),

          // Zigzag bottom edge
          CustomPaint(
            painter: ZigzagPainter(isTop: false),
            size: const Size(double.infinity, 10),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '1xKing',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDottedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              (constraints.maxWidth / 5).floor(),
              (index) => Container(
                width: 2,
                height: 1,
                color: Colors.grey[400],
                margin: const EdgeInsets.symmetric(horizontal: 1),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTicketHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(
          3,
          (index) =>
              const Icon(Icons.star_border, size: 14, color: Colors.grey),
        ),
        const SizedBox(width: 8),
        const Text(
          'TICKET',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 8),
        ...List.generate(
          3,
          (index) =>
              const Icon(Icons.star_border, size: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildBetDetails() {
    // Get the ticket number from API data or use a default
    final ticketNumber =
        _invoiceNumber.isNotEmpty ? _invoiceNumber : 'TK-12345678';

    // Get username from API data or use provided value
    final username =
        _userName.isNotEmpty ? _userName : (widget.userName ?? 'User');

    // Format date
    final date =
        _date.isNotEmpty
            ? _formatDate(_date)
            : DateTime.now().toString().substring(0, 16);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Ticket No', ticketNumber),
          const SizedBox(height: 4),
          _buildDetailRow('Username', username),
          const SizedBox(height: 4),
          _buildDetailRow('Date', date),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildBetItemsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: const [
          Expanded(
            flex: 1,
            child: Text(
              'နံပါတ်',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'count*ငွေ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'ထိုးငွေ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBetItemsList() {
    List<Widget> betItemWidgets = [];

    // If we have API lottery digits data, use it
    if (_lotteryDigits.isNotEmpty) {
      Map<String, List<dynamic>> groupedByAmount = {};

      // Group digits by amount
      for (var digit in _lotteryDigits) {
        final String number = digit['permanent_number']['permanent_number'];
        final int amount = digit['sub_amount'];
        final String amountStr = _formatAmount(amount);

        if (!groupedByAmount.containsKey(amountStr)) {
          groupedByAmount[amountStr] = [];
        }
        groupedByAmount[amountStr]!.add(digit);
      }

      // Build widgets for each amount group
      groupedByAmount.forEach((amountStr, digits) {
        if (digits.length > 1) {
          // Multiple digits with same amount
          final String numbers = digits
              .map<String>((d) => d['permanent_number']['permanent_number'])
              .join(',');
          final int totalAmount =
              int.parse(amountStr.replaceAll(',', '')) * digits.length;

          betItemWidgets.add(
            _buildBetItemRow(
              numbers,
              digits.length,
              amountStr,
              _formatAmount(totalAmount),
            ),
          );
        } else {
          // Single digit
          final digit = digits.first;
          final String number = digit['permanent_number']['permanent_number'];
          betItemWidgets.add(_buildBetItemRow(number, 1, amountStr, amountStr));
        }
      });

      return betItemWidgets;
    }

    // If we have traditional bet items, use those
    if (widget.betItems != null && widget.betItems!.isNotEmpty) {
      // Filter out items with empty amounts
      List<BetItem> validBetItems =
          widget.betItems!.where((item) => item.amount.isNotEmpty).toList();

      // Group items by amount for easier grouping
      Map<String, List<BetItem>> groupedByAmount = {};

      // First, group all items by their amount
      for (var item in validBetItems) {
        if (!groupedByAmount.containsKey(item.amount)) {
          groupedByAmount[item.amount] = [];
        }
        groupedByAmount[item.amount]!.add(item);
      }

      // Process each amount group
      groupedByAmount.forEach((amount, items) {
        // If multiple items have the same amount, combine them
        if (items.length > 1) {
          // Join numbers with commas as shown in ref3.png
          String numbers = items.map((item) => item.number).join(',');
          int totalAmount =
              int.parse(amount.replaceAll(',', '')) * items.length;

          betItemWidgets.add(
            _buildBetItemRow(
              numbers,
              items.length,
              amount,
              _formatAmount(totalAmount),
            ),
          );
        } else {
          // Single item with this amount
          BetItem item = items.first;
          betItemWidgets.add(
            _buildBetItemRow(item.number, 1, item.amount, item.amount),
          );
        }
      });

      return betItemWidgets;
    }

    // Show sample entries for demonstration purposes
    return [
      _buildBetItemRow("34,96,34,23,88,20,23", 12, "2,000", "24,000"),
      _buildBetItemRow("56", 1, "3,000", "3,000"),
      _buildBetItemRow("46", 1, "4,000", "4,000"),
      _buildBetItemRow("11", 1, "5,000", "5,000"),
      _buildBetItemRow("22", 1, "6,000", "6,000"),
    ];
  }

  Widget _buildBetItemRow(
    String number,
    int count,
    String amount,
    String total,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              number,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '$count*$amount',
              style: const TextStyle(fontSize: 14, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              total,
              style: const TextStyle(fontSize: 14, color: Colors.black),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow() {
    final displayAmount =
        _totalAmount > 0
            ? _formatAmount(_totalAmount)
            : (widget.totalAmount != null
                ? _formatAmount(widget.totalAmount!)
                : "0");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          const Expanded(
            flex: 1,
            child: Text(
              'Total',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const Expanded(flex: 1, child: SizedBox()),
          Expanded(
            flex: 1,
            child: Text(
              '$displayAmount Ks',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    // Adjust padding for iOS to account for the home indicator
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final EdgeInsets padding = EdgeInsets.only(
      left: 16,
      right: 16,
      bottom: isIOS ? 24.0 : 16.0,
      top: 16,
    );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _isSaving ? null : _saveScreenshot,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primaryColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isSaving ? Icons.hourglass_empty : Icons.save_alt,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      _isSaving ? 'Saving...' : 'သိမ်းဆည်းရန်',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Navigate to home and clear all screens in between
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.fromWinningRecords ? Icons.arrow_back : Icons.home,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      widget.fromWinningRecords ? 'နောက်သို့' : 'ပင်မစာမျက်နှာ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveScreenshot() async {
    setState(() {
      _isSaving = true;
    });

    try {
      print('Starting screenshot capture process');
      Uint8List? imageBytes;
      try {
        // Capture screenshot using the updated API
        print('Attempting to capture screenshot...');
        imageBytes = await _screenshotController.capture(
          delay: const Duration(milliseconds: 10),
          pixelRatio: MediaQuery.of(context).devicePixelRatio,
        );
        print(
          'Screenshot captured successfully. Size: ${imageBytes?.length ?? 0} bytes',
        );
      } catch (screenshotError) {
        print('Error capturing screenshot: $screenshotError');
        print('Error details: ${screenshotError.toString()}');
        _showErrorMessage('Error capturing screenshot: $screenshotError');
        setState(() {
          _isSaving = false;
        });
        return;
      }

      if (imageBytes != null) {
        try {
          // Check permissions first
          print('Checking permissions...');
          bool permissionGranted = await _checkAndRequestPermissions();
          print('Permission granted: $permissionGranted');
          
          // For Android 10+, we might still proceed even if permission appears denied
          // because saver_gallery handles it internally
          if (!permissionGranted && Platform.isIOS) {
            _showErrorMessage('Permission denied. Cannot save screenshot.');
            setState(() {
              _isSaving = false;
            });
            return;
          }

          // Save image directly to gallery using saver_gallery
          print('Attempting to save image to gallery...');
          final fileName =
              'BetMM_Ticket_${DateTime.now().millisecondsSinceEpoch}.png';
          print('File name: $fileName');

          try {
            // Simplified save approach - let saver_gallery handle the details
            dynamic result;
            
            // For all platforms, use the standard saveImage method
            print('Saving image to gallery...');
            result = await SaverGallery.saveImage(
              imageBytes,
              fileName: fileName,
              quality: 100,
              skipIfExists: false,
              androidRelativePath: Platform.isAndroid ? "Pictures/BetMM" : null,
            );

            print('SaverGallery result: $result (${result.runtimeType})');

            // Handle different types of results
            bool saveSuccess = false;
            
            // The plugin returns a SaveResult object, check if it's successful
            if (result != null) {
              final resultStr = result.toString();
              print('Result string: $resultStr');
              
              // Check for success indicators
              if (resultStr.contains('isSuccess: true') || 
                  resultStr.contains('true') ||
                  (result is bool && result == true)) {
                saveSuccess = true;
              }
            }

            if (saveSuccess) {
              print('Image saved successfully');
              _showSuccessMessage('Ticket saved to gallery successfully');
            } else {
              print('Save failed. Result: $result');
              
              // Try alternative method using temp file
              print('Trying alternative save method...');
              final tempDir = await getTemporaryDirectory();
              final tempFile = File('${tempDir.path}/$fileName');
              await tempFile.writeAsBytes(imageBytes);
              
              // Try saving the file directly
              final altResult = await SaverGallery.saveFile(
                filePath: tempFile.path,
                fileName: fileName,
                skipIfExists: false,
                androidRelativePath: Platform.isAndroid ? "Pictures/BetMM" : null,
              );
              
              print('Alternative save result: $altResult');
              
              // Clean up temp file
              try {
                await tempFile.delete();
              } catch (_) {}
              
              final altResultStr = altResult.toString();
              if (altResultStr.contains('isSuccess: true') || 
                  altResultStr.contains('true') ||
                  (altResult is bool && altResult == true)) {
                _showSuccessMessage('Ticket saved to gallery successfully');
              } else {
                _showErrorMessage('Failed to save ticket to gallery. Please check permissions.');
              }
            }
          } catch (saveError) {
            print('Error during save: $saveError');
            
            // If it's a permission error, show appropriate message
            if (saveError.toString().toLowerCase().contains('permission')) {
              _showErrorMessage('Permission denied. Please grant storage permission in settings.');
              _showPermissionPermanentlyDeniedDialog();
            } else {
              _showErrorMessage('Failed to save ticket: ${saveError.toString()}');
            }
          }
        } catch (e) {
          print('Error saving to gallery: $e');
          _showErrorMessage('Error saving to gallery: ${e.toString()}');
        }
      } else {
        print('Screenshot capture failed - imageBytes is null');
        _showErrorMessage('Failed to capture screenshot');
      }
    } catch (e, stackTrace) {
      print('Error saving screenshot: $e');
      print('Stack trace: $stackTrace');
      _showErrorMessage('Error saving screenshot: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // Check and request required permissions based on platform
  Future<bool> _checkAndRequestPermissions() async {
    print('Platform: ${Platform.operatingSystem}');

    if (Platform.isAndroid) {
      print('Checking Android permissions...');
      
      // Get Android SDK version
      final androidInfo = await _getAndroidSdkVersion();
      print('Android SDK version: $androidInfo');
      
      // For Android 13+ (API 33+), we need to check media permissions
      if (androidInfo >= 33) {
        print('Android 13+ detected. Checking photos permission...');
        var photosStatus = await Permission.photos.status;
        print('Photos permission status: $photosStatus');
        
        if (!photosStatus.isGranted) {
          print('Requesting photos permission...');
          photosStatus = await Permission.photos.request();
          print('Photos permission after request: $photosStatus');
          
          if (photosStatus.isPermanentlyDenied) {
            print('Photos permission permanently denied');
            _showPermissionPermanentlyDeniedDialog();
            return false;
          }
        }
        
        // For Android 13+, also check if we need READ_MEDIA_IMAGES
        if (!photosStatus.isGranted) {
          // Try with storage permission as fallback
          var storageStatus = await Permission.storage.status;
          if (!storageStatus.isGranted) {
            storageStatus = await Permission.storage.request();
          }
          // Even if denied, let saver_gallery try as it might handle it internally
          return true;
        }
        
        return photosStatus.isGranted;
      } else if (androidInfo >= 29) {
        // For Android 10-12 (API 29-32), saver_gallery handles permissions internally
        print('Android 10-12 detected. SaverGallery handles permissions internally.');
        // Still check storage permission just in case
        var storageStatus = await Permission.storage.status;
        if (!storageStatus.isGranted && !storageStatus.isRestricted) {
          print('Requesting storage permission...');
          storageStatus = await Permission.storage.request();
        }
        // Return true regardless as saver_gallery should handle it
        return true;
      } else {
        // For Android 9 and below, we need storage permission
        print('Android 9 or below detected. Checking storage permission...');
        var storageStatus = await Permission.storage.status;
        print('Storage permission status: $storageStatus');
        
        if (!storageStatus.isGranted) {
          print('Requesting storage permission...');
          storageStatus = await Permission.storage.request();
          print('Storage permission after request: $storageStatus');
          
          if (storageStatus.isPermanentlyDenied) {
            print('Storage permission permanently denied');
            _showPermissionPermanentlyDeniedDialog();
            return false;
          }
        }
        
        return storageStatus.isGranted;
      }
    } else if (Platform.isIOS) {
      print('Checking iOS permissions...');
      
      // For iOS, we need photos permission
      print('Checking iOS photos permissions...');
      
      // First check the current status
      var photosStatus = await Permission.photos.status;
      var addOnlyStatus = await Permission.photosAddOnly.status;
      
      print('Photos permission status: $photosStatus');
      print('Photos add-only permission status: $addOnlyStatus');
      
      // If we already have some permission, return true
      if (photosStatus.isGranted || photosStatus.isLimited || 
          addOnlyStatus.isGranted || addOnlyStatus.isLimited) {
        print('Photos permission already granted');
        return true;
      }
      
      // If permanently denied, show dialog
      if (photosStatus.isPermanentlyDenied || addOnlyStatus.isPermanentlyDenied) {
        print('Photos permission permanently denied, showing dialog');
        _showPermissionPermanentlyDeniedDialog();
        return false;
      }
      
      // Request permission - try add-only first as it's less intrusive
      print('Requesting photos add-only permission...');
      addOnlyStatus = await Permission.photosAddOnly.request();
      print('Photos add-only permission after request: $addOnlyStatus');
      
      if (addOnlyStatus.isGranted || addOnlyStatus.isLimited) {
        return true;
      }
      
      // If add-only didn't work, try full photos permission
      print('Requesting full photos permission...');
      photosStatus = await Permission.photos.request();
      print('Full photos permission after request: $photosStatus');
      
      if (photosStatus.isPermanentlyDenied) {
        _showPermissionPermanentlyDeniedDialog();
        return false;
      }
      
      return photosStatus.isGranted || photosStatus.isLimited;
    }

    print('Unsupported platform for permissions check');
    return false;
  }
  
  // Helper method to get Android SDK version
  Future<int> _getAndroidSdkVersion() async {
    if (Platform.isAndroid) {
      try {
        // Try to parse SDK version from operatingSystemVersion
        final osVersion = Platform.operatingSystemVersion;
        // Extract SDK version from string like "Android 13 (API 33)"
        final match = RegExp(r'API (\d+)').firstMatch(osVersion);
        if (match != null) {
          return int.parse(match.group(1)!);
        }
        
        // Fallback: try to get version number from beginning
        final versionMatch = RegExp(r'Android (\d+)').firstMatch(osVersion);
        if (versionMatch != null) {
          final androidVersion = int.parse(versionMatch.group(1)!);
          // Convert Android version to API level (rough estimate)
          // Android 10 = API 29, Android 11 = API 30, etc.
          return androidVersion + 19;
        }
      } catch (e) {
        print('Error parsing Android version: $e');
      }
    }
    // Default to API 28 (Android 9) if we can't determine
    return 28;
  }

  // Show dialog when permissions are permanently denied
  void _showPermissionPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'Photo library permission is required to save screenshots. '
            'Please enable it in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class ZigzagPainter extends CustomPainter {
  final bool isTop;

  ZigzagPainter({required this.isTop});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final Path path = Path();
    final double width = size.width;
    final double height = size.height;

    // Create small triangular cuts for the zigzag edge
    final double triangleWidth =
        width / 25; // More triangles for a smoother edge

    if (isTop) {
      // Start from bottom-left for top zigzag
      path.moveTo(0, height);

      // Draw triangular cuts across the top
      for (int i = 0; i < width ~/ triangleWidth; i++) {
        path.lineTo((i * triangleWidth) + (triangleWidth / 2), 0);
        path.lineTo((i + 1) * triangleWidth, height);
      }

      // Ensure we close the path
      path.lineTo(width, height);
      path.lineTo(0, height);
    } else {
      // Start from top-left for bottom zigzag
      path.moveTo(0, 0);

      // Add the right edge
      path.lineTo(width, 0);

      // Draw triangular cuts across the bottom in reverse
      for (int i = width ~/ triangleWidth; i >= 0; i--) {
        path.lineTo((i * triangleWidth) + (triangleWidth / 2), height);
        path.lineTo(i * triangleWidth, 0);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldPainter) => false;
}
