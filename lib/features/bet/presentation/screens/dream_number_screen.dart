import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/bet/domain/models/dream_list.dart';
import 'package:one_x/features/bet/data/repositories/bet_repository.dart';
import 'package:one_x/features/bet/presentation/providers/bet_provider.dart';
import 'package:one_x/features/home/presentation/providers/home_provider.dart';

class DreamNumberScreen extends ConsumerStatefulWidget {
  final String type; // '2D' or '3D'

  const DreamNumberScreen({super.key, this.type = '2D'});

  @override
  ConsumerState<DreamNumberScreen> createState() => _DreamNumberScreenState();
}

class _DreamNumberScreenState extends ConsumerState<DreamNumberScreen> {
  bool _isLoading = true;
  List<Dreams> _dreams = [];

  @override
  void initState() {
    super.initState();
    _fetchDreamNumbers();
  }

  Future<void> _fetchDreamNumbers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(betRepositoryProvider);
      final dreamListResponse =
          widget.type == '3D'
              ? await repository.get3DDreamNumbers()
              : await repository.get2DDreamNumbers();

      setState(() {
        _dreams = dreamListResponse.dreams ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching dream numbers: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load dream numbers: $e'),
            duration: const Duration(seconds: 3),
          ),
        );

        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.type == '3D' ? 'အိမ်မက်' : 'Dream',
          style: TextStyle(color: AppTheme.textColor),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _dreams.isEmpty
              ? Center(
                child: Text(
                  'No dream numbers available',
                  style: TextStyle(color: AppTheme.textColor),
                ),
              )
              : Column(
                children: [
                  _buildBalanceInfo(),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.74,
                          ),
                      itemCount: _dreams.length,
                      itemBuilder: (context, index) {
                        final dream = _dreams[index];
                        return _buildDreamCard(dream, isLightTheme);
                      },
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildBalanceInfo() {
    // Get the user's balance from your state management (e.g., Riverpod)
    final homeData = ref.watch(homeDataProvider);

    return homeData.when(
      data:
          (data) => Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Balance -${_formatAmount(data.user.balance)} MMK',
              style: TextStyle(
                color: AppTheme.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      loading:
          () => Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Balance Loading...',
              style: TextStyle(
                color: AppTheme.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      error:
          (error, stack) => Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Balance Error',
              style: TextStyle(
                color: AppTheme.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
    );
  }

  Widget _buildDreamCard(Dreams dream, bool isLightTheme) {
    return GestureDetector(
      onTap: () {
        // Only return valid numbers for the selected bet type
        final List<String> selectedNumbers = [];

        if (dream.number1 != null && dream.number1!.isNotEmpty) {
          // For 2D, we need 2-digit numbers, for 3D we need 3-digit numbers
          if ((widget.type == '2D' && dream.number1!.length == 2) ||
              (widget.type == '3D' && dream.number1!.length == 3)) {
            selectedNumbers.add(dream.number1!);
          }
        }

        if (dream.number2 != null && dream.number2!.isNotEmpty) {
          // For 2D, we need 2-digit numbers, for 3D we need 3-digit numbers
          if ((widget.type == '2D' && dream.number2!.length == 2) ||
              (widget.type == '3D' && dream.number2!.length == 3)) {
            selectedNumbers.add(dream.number2!);
          }
        }

        // Close the screen and return selected numbers
        Navigator.pop(context, selectedNumbers);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isLightTheme ? Colors.white : Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLightTheme ? Colors.grey[300]! : Colors.grey[800]!,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                dream.url ?? '',
                width: double.infinity,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 110,
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dream.name ?? 'Unknown',
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildNumberButton(dream.number1 ?? ''),
                      const SizedBox(width: 8),
                      _buildNumberButton(dream.number2 ?? ''),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return Container(
      width: 45,
      height: 35,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
