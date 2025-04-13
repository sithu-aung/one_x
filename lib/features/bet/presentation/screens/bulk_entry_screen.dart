import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/bet/presentation/screens/amount_entry_screen.dart';
import 'package:one_x/features/home/presentation/providers/home_provider.dart';
import 'package:one_x/features/home/data/models/home_model.dart';

class BulkEntryScreen extends ConsumerStatefulWidget {
  final String sessionName;

  const BulkEntryScreen({super.key, required this.sessionName});

  @override
  ConsumerState<BulkEntryScreen> createState() => _BulkEntryScreenState();
}

class _BulkEntryScreenState extends ConsumerState<BulkEntryScreen> {
  final TextEditingController _textController = TextEditingController();
  List<String> _pastedLines = [];
  bool _hasContent = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handlePaste() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      setState(() {
        _textController.text = data.text!;
        _pastedLines =
            data.text!
                .split("\n")
                .where((line) => line.trim().isNotEmpty)
                .toList();
        _hasContent = _pastedLines.isNotEmpty;
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ထိုးမည့် ကိန်းများ',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          _buildInstructions(),
          Expanded(
            child: _hasContent ? _buildPastedContent() : _buildPasteArea(),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'သတ်မှတ်ချက်',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '01 = 1000\n02 = 2000\n03 = 5000',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          SizedBox(height: 8),
          Text(
            '*Copy ကူးထားသည့် format မှာ အထက်ပါအတိုင်း ဖြစ်ရန် လိုပါသည်။',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          Text(
            '*နံပါတ်တစ်ခု/ တစ်ကြောင်းစီအတွက် ဖြစ်ရန်လဲ မဖြစ်မနေလိုပါသည်။',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPasteArea() {
    return GestureDetector(
      onTap: _handlePaste,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Paste here..',
            style: TextStyle(color: Colors.white60, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildPastedContent() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          ListView.builder(
            itemCount: _pastedLines.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  _pastedLines[index],
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              );
            },
          ),
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _textController.clear();
                  _pastedLines = [];
                  _hasContent = false;
                });
              },
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final bottomPadding = isIOS ? MediaQuery.of(context).padding.bottom : 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + bottomPadding.toDouble(),
      ),
      child: GestureDetector(
        onTap:
            _hasContent
                ? () {
                  // Process the pasted numbers and navigate
                  List<String> processedNumbers = _processNumbers();
                  if (processedNumbers.isNotEmpty) {
                    try {
                      // Get home data from provider
                      final homeData = ref.read(homeDataProvider);

                      // Only proceed if home data is available
                      if (homeData is AsyncData) {
                        // Get user data from the response
                        final User user = homeData.value!.user;

                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AmountEntryScreen(
                                    selectedNumbers: processedNumbers,
                                    sessionName: widget.sessionName,
                                    userName: user.username,
                                    userId: user.id,
                                  ),
                            ),
                          );
                        }
                      } else {
                        // Show message if data is not available
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'User data is not available. Please try again.',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  }
                }
                : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.primaryColor),
          ),
          child: const Center(
            child: Text(
              'နောက်တစ်ဆင့်',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to process the pasted numbers
  List<String> _processNumbers() {
    final List<String> processedNumbers = [];

    for (String line in _pastedLines) {
      // Basic processing - extracting just the number part
      final parts = line.split('=');
      if (parts.isNotEmpty) {
        String number = parts[0].trim();
        // Ensure it's a valid 2-digit number
        if (number.length == 2 && int.tryParse(number) != null) {
          processedNumbers.add(number);
        }
      }
    }

    return processedNumbers;
  }
}
