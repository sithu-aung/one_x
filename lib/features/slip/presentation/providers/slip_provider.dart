import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/features/auth/presentation/providers/auth_provider.dart';
import 'package:one_x/features/slip/data/models/slip_model.dart';
import 'package:one_x/features/slip/data/repositories/slip_repository.dart';

// SlipRepository provider
final slipRepositoryProvider = Provider<SlipRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return SlipRepository(apiService: apiService, storageService: storageService);
});

// Slip details provider
final slipDetailsProvider = FutureProvider.family<SlipModel, int>((
  ref,
  slipId,
) async {
  final repository = ref.watch(slipRepositoryProvider);
  return repository.getSlipDetails(slipId);
});
