import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/features/auth/presentation/providers/auth_provider.dart';
import 'package:one_x/features/threed/data/models/threed_models.dart';
import 'package:one_x/features/threed/data/repositories/threed_repository.dart';

// ThreeDRepository provider
final threeDRepositoryProvider = Provider<ThreeDRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return ThreeDRepository(
    apiService: apiService,
    storageService: storageService,
  );
});

// ThreeD Play Info provider
final threeDPlayInfoProvider = FutureProvider<ThreeDPlayInfo>((ref) async {
  final repository = ref.watch(threeDRepositoryProvider);
  return repository.getPlayInfo();
});

// ThreeD History provider
final threeDHistoryProvider = FutureProvider<ThreeDHistory>((ref) async {
  final repository = ref.watch(threeDRepositoryProvider);
  return repository.getHistory();
});

// ThreeD Winning Numbers provider
final threeDWinningNumbersProvider = FutureProvider<ThreeDWinningNumbers>((
  ref,
) async {
  final repository = ref.watch(threeDRepositoryProvider);
  return repository.getWinningNumbers();
});

// ThreeD Play Data provider
final threeDPlayDataProvider = FutureProvider<ThreeDPlayData>((ref) async {
  final repository = ref.watch(threeDRepositoryProvider);
  return repository.get3DPlay();
});

// ThreeD Manual Play Data provider
final threeDManualPlayDataProvider = FutureProvider<ThreeDManualPlayData>((
  ref,
) async {
  final repository = ref.watch(threeDRepositoryProvider);
  return repository.get3DManualPlay();
});

// ThreeD Copy Paste Data provider
final threeDCopyPasteDataProvider = FutureProvider<ThreeDCopyPasteData>((
  ref,
) async {
  final repository = ref.watch(threeDRepositoryProvider);
  return repository.get3DCopyPaste();
});

// ThreeD Daily History provider
final threeDDailyHistoryProvider = FutureProvider<ThreeDDailyHistory>((
  ref,
) async {
  final repository = ref.watch(threeDRepositoryProvider);
  return repository.getDailyHistory();
});

// ThreeD Daily Record provider
final threeDDailyRecordProvider = FutureProvider<ThreeDDailyRecord>((
  ref,
) async {
  final repository = ref.watch(threeDRepositoryProvider);
  return repository.getDailyRecord();
});

// ThreeD Monthly History provider
final threeDMonthlyHistoryProvider = FutureProvider<ThreeDMonthlyHistory>((
  ref,
) async {
  final repository = ref.watch(threeDRepositoryProvider);
  return repository.getMonthlyHistory();
});

// ThreeD First Half Monthly History provider
final threeDFirstHalfMonthlyHistoryProvider =
    FutureProvider<ThreeDHalfMonthlyHistory>((ref) async {
      final repository = ref.watch(threeDRepositoryProvider);
      return repository.getFirstHalfMonthHistory();
    });

// ThreeD Second Half Monthly History provider
final threeDSecondHalfMonthlyHistoryProvider =
    FutureProvider<ThreeDHalfMonthlyHistory>((ref) async {
      final repository = ref.watch(threeDRepositoryProvider);
      return repository.getSecondHalfMonthHistory();
    });

// ThreeD Submit provider - This is a family provider that takes a submit request
final threeDSubmitProvider =
    FutureProvider.family<ThreeDSubmitResponse, ThreeDSubmitRequest>((
      ref,
      request,
    ) async {
      final repository = ref.watch(threeDRepositoryProvider);
      return repository.submit3DBet(request);
    });
