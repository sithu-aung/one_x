import 'package:one_x/core/constants/app_constants.dart';
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/core/utils/api_service.dart';
import 'package:one_x/features/slip/data/models/slip_model.dart';

class SlipRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  SlipRepository({
    required ApiService apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService;

  /// Fetches details of a specific betting slip by ID
  Future<SlipModel> getSlipDetails(int slipId) async {
    try {
      final endpoint = AppConstants.showSlipEndpoint.replaceAll(
        '{id}',
        slipId.toString(),
      );
      final response = await _apiService.get(endpoint);
      return SlipModel.fromJson(response['slip']);
    } catch (e) {
      throw Exception('Failed to load slip details: $e');
    }
  }
}
