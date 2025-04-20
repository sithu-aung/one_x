import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/utils/api_service.dart';
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/features/auth/presentation/providers/auth_provider.dart';
import 'package:one_x/features/bet/data/repositories/bet_repository.dart';
import 'package:one_x/features/bet/domain/models/two_d_session_status_list_response.dart';

// BetRepository provider
final betRepositoryProvider = Provider<BetRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return BetRepository(apiService: apiService, storageService: storageService);
});

// Provider for active 2D sessions
final active2DSessionsProvider = FutureProvider<TwoDSessionStatusListResponse>((ref) async {
  final repository = ref.watch(betRepositoryProvider);
  return repository.getActive2DSessions();
});


// Provider for 2D live results
final twoDigitLiveResultsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final repository = ref.watch(betRepositoryProvider);
  return repository.get2DLiveResults();
});
