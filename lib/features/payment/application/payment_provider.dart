import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:one_x/core/utils/api_service.dart';
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/core/constants/app_constants.dart';
import 'package:one_x/features/payment/domain/models/payment_model.dart';
import 'package:one_x/features/payment/domain/models/transaction_history.dart'
    as tx_history;
import 'package:one_x/features/home/presentation/providers/home_provider.dart';

// Payment Repository
class PaymentRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  PaymentRepository({
    required ApiService apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService;

  // Get wallet transaction history
  Future<Map<String, dynamic>> getWalletHistory() async {
    try {
      final response = await _apiService.get(
        AppConstants.walletHistoryEndpoint,
      );
      return response;
    } catch (error) {
      print('Error fetching wallet history: $error');
      rethrow;
    }
  }

  // Get transaction details by ID
  Future<Map<String, dynamic>> getTransactionDetails(
    String transactionId,
  ) async {
    try {
      final endpoint = AppConstants.transactionDetailEndpoint.replaceAll(
        '{id}',
        transactionId,
      );
      final response = await _apiService.get(endpoint);
      return response;
    } catch (error) {
      print('Error fetching transaction details: $error');
      rethrow;
    }
  }

  // Cancel a transaction by ID
  Future<Map<String, dynamic>> cancelTransaction(String transactionId) async {
    try {
      final endpoint = AppConstants.cancelTransactionEndpoint.replaceAll(
        '{id}',
        transactionId,
      );
      final response = await _apiService.delete(endpoint);
      return response;
    } catch (error) {
      print('Error cancelling transaction: $error');
      rethrow;
    }
  }

  // Get payment providers for top-up
  Future<PaymentProvidersResponse> getPaymentProviders() async {
    try {
      final response = await _apiService.get('/api/api-provider');
      return PaymentProvidersResponse.fromJson(response);
    } catch (error) {
      print('Error fetching payment providers: $error');
      rethrow;
    }
  }

  // Get payment providers for withdrawal
  Future<PaymentProvidersResponse> getWithdrawalProviders() async {
    try {
      final response = await _apiService.get('/api/api-provider');
      return PaymentProvidersResponse.fromJson(response);
    } catch (error) {
      print('Error fetching withdrawal providers: $error');
      rethrow;
    }
  }

  // Process a top-up request
  Future<Map<String, dynamic>> processTopUp({
    required String providerKey,
    required double amount,
    required String currency,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/topup',
        body: {
          'provider_key': providerKey,
          'amount': amount,
          'currency': currency,
        },
      );
      return response;
    } catch (error) {
      print('Error processing top-up: $error');
      rethrow;
    }
  }

  // Process a withdrawal request
  Future<Map<String, dynamic>> processWithdrawal({
    required String providerKey,
    required double amount,
    required String currency,
    required String accountNumber,
    String? remarks,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/withdraw',
        body: {
          'provider_key': providerKey,
          'amount': amount,
          'currency': currency,
          'account_number': accountNumber,
          if (remarks != null) 'remarks': remarks,
        },
      );
      return response;
    } catch (error) {
      print('Error processing withdrawal: $error');
      rethrow;
    }
  }

  // Process a store-deposit request
  Future<Map<String, dynamic>> storeDeposit({
    required int providerId,
    required int billingId,
    required String amount,
    required String accountNumber,
    required String userName,
    required String transactionId,
    required int userId,
    String? remark,
  }) async {
    try {
      // Ensure data is properly formatted for API
      final Map<String, dynamic> requestBody = {
        'provider_id': providerId,
        'billing_id': billingId,
        'sender_amount': amount,
        'sender_account': accountNumber,
        'sender_name': userName,
        'transaction_type': 'deposit',
        'transaction_id': transactionId,
        'remark': remark ?? '',
        'sender_id': userId,
        'receipt_id': 1, // Fixed value as per requirements
      };

      print('Deposit request: $requestBody'); // Log the request for debugging

      final response = await _apiService.post(
        AppConstants.storeDepositEndpoint,
        body: requestBody,
      );
      return response;
    } catch (error) {
      print('Error processing deposit: $error');
      rethrow;
    }
  }

  // Process a store-withdraw request
  Future<Map<String, dynamic>> storeWithdraw({
    required int providerId,
    required int billingId,
    required String amount,
    required String accountNumber,
    required String userName,
    required int userId,
    String? transactionId,
    String? remark,
  }) async {
    try {
      // Ensure data is properly formatted for API
      final Map<String, dynamic> requestBody = {
        'provider_id': providerId,
        'billing_id': billingId,
        'sender_amount': amount,
        'sender_account': accountNumber,
        'sender_name': userName,
        'transaction_type': 'withdraw',
        'sender_id': userId,
        'receipt_id': 1, // Fixed value as per requirements
      };

      // Only add optional fields if they're not null
      if (transactionId != null) {
        requestBody['transaction_id'] = transactionId;
      }

      if (remark != null) {
        requestBody['remark'] = remark;
      }

      print(
        'Withdrawal request: $requestBody',
      ); // Log the request for debugging

      final response = await _apiService.post(
        AppConstants.storeWithdrawEndpoint,
        body: requestBody,
      );
      return response;
    } catch (error) {
      print('Error processing withdrawal: $error');
      rethrow;
    }
  }
}

// Repository provider
final paymentRepositoryProvider = riverpod.Provider<PaymentRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return PaymentRepository(
    apiService: apiService,
    storageService: storageService,
  );
});

// API service provider
final apiServiceProvider = riverpod.Provider<ApiService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ApiService(storageService: storageService);
});

// Transaction history provider
final transactionHistoryProvider = riverpod
    .FutureProvider.autoDispose<tx_history.TransactionHistoryResponse>((
  ref,
) async {
  final repository = ref.watch(paymentRepositoryProvider);
  final response = await repository.getWalletHistory();
  return tx_history.TransactionHistoryResponse.fromJson(response);
});

// Provider for payment providers (top-up options)
final paymentProvidersProvider = riverpod
    .FutureProvider.autoDispose<PaymentProvidersResponse>((ref) async {
  final repository = ref.watch(paymentRepositoryProvider);
  return await repository.getPaymentProviders();
});

// Provider for withdrawal providers
final withdrawalProvidersProvider =
    riverpod.FutureProvider<List<PaymentProviderModel>>((ref) async {
      final repository = ref.read(paymentRepositoryProvider);
      try {
        final response = await repository.getWithdrawalProviders();
        return response.providers;
      } catch (e) {
        print('Error in withdrawalProvidersProvider: $e');
        return [];
      }
    });

// Storage service provider
final storageServiceProvider = riverpod.Provider<StorageService>((ref) {
  return StorageService();
});

// Transaction details provider
final transactionDetailsProvider = riverpod
    .FutureProvider.family<dynamic, String>((ref, transactionId) async {
  final repository = ref.watch(paymentRepositoryProvider);
  try {
    final response = await repository.getTransactionDetails(transactionId);
    return response;
  } catch (e) {
    print('Error in transactionDetailsProvider: $e');
    rethrow;
  }
});

// Transaction cancellation provider
final cancelTransactionProvider = riverpod
    .FutureProvider.family<dynamic, String>((ref, transactionId) async {
  final repository = ref.watch(paymentRepositoryProvider);
  try {
    final response = await repository.cancelTransaction(transactionId);
    return response;
  } catch (e) {
    print('Error in cancelTransactionProvider: $e');
    rethrow;
  }
});

class PaymentState {
  final String preferredCurrency;
  final Balance? balance;
  final bool isLoading;
  final ExchangeRate? exchangeRate;
  final List<TransactionModel> transactions;
  final List<PaymentProviderModel> paymentProviders;
  final List<PaymentProviderModel> withdrawalProviders;

  PaymentState({
    required this.preferredCurrency,
    this.balance,
    this.isLoading = false,
    this.exchangeRate,
    this.transactions = const [],
    this.paymentProviders = const [],
    this.withdrawalProviders = const [],
  });

  PaymentState copyWith({
    String? preferredCurrency,
    Balance? balance,
    bool? isLoading,
    ExchangeRate? exchangeRate,
    List<TransactionModel>? transactions,
    List<PaymentProviderModel>? paymentProviders,
    List<PaymentProviderModel>? withdrawalProviders,
  }) {
    return PaymentState(
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      balance: balance ?? this.balance,
      isLoading: isLoading ?? this.isLoading,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      transactions: transactions ?? this.transactions,
      paymentProviders: paymentProviders ?? this.paymentProviders,
      withdrawalProviders: withdrawalProviders ?? this.withdrawalProviders,
    );
  }
}

class Balance {
  final int amount;
  final String currency;

  Balance({required this.amount, required this.currency});
}

class ExchangeRate {
  final double rate;
  final String fromCurrency;
  final String toCurrency;

  ExchangeRate({
    required this.rate,
    required this.fromCurrency,
    required this.toCurrency,
  });
}

class PaymentNotifier extends riverpod.StateNotifier<PaymentState> {
  PaymentNotifier(this.ref)
    : super(
        PaymentState(
          preferredCurrency: 'MMK',
          balance: Balance(amount: 0, currency: 'MMK'),
        ),
      );

  final riverpod.Ref ref;

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true);

    try {
      // Get real user data from homeUserProvider
      final homeDataAsyncValue = await ref.read(homeDataProvider.future);
      final userData = homeDataAsyncValue.user;

      // Update payment state with real user balance
      state = state.copyWith(
        balance: Balance(
          amount: userData.balance,
          currency: state.preferredCurrency,
        ),
        exchangeRate: ExchangeRate(
          rate: 4500, // This could also come from an API in the future
          fromCurrency: 'USD',
          toCurrency: 'MMK',
        ),
        isLoading: false,
      );
    } catch (e) {
      // Fallback to default values if home data can't be fetched
      state = state.copyWith(
        balance: Balance(amount: 0, currency: state.preferredCurrency),
        isLoading: false,
      );
    }
  }

  Future<void> loadPaymentProviders() async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(paymentRepositoryProvider);
      final response = await repository.getPaymentProviders();

      state = state.copyWith(
        paymentProviders: response.providers,
        isLoading: false,
      );
    } catch (e) {
      print('Error loading payment providers: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadWithdrawalProviders() async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(paymentRepositoryProvider);
      final response = await repository.getWithdrawalProviders();

      state = state.copyWith(
        withdrawalProviders: response.providers,
        isLoading: false,
      );
    } catch (e) {
      print('Error loading withdrawal providers: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true);

    try {
      // TODO: Replace with actual API call when available
      // In a real application, this would call a repository method to fetch transactions
      // For now, we'll use mock data after a delay to simulate network request
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock transaction data as fallback
      final transactions = [
        TransactionModel(
          id: 'tx001',
          amount: 50000,
          currency: 'MMK',
          type: TransactionType.topUp,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          status: 'Completed',
          description: 'Deposit via KBZ Pay',
        ),
        TransactionModel(
          id: 'tx002',
          amount: 25000,
          currency: 'MMK',
          type: TransactionType.withdraw,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          status: 'Completed',
          description: 'Withdraw to Wave Pay',
        ),
        TransactionModel(
          id: 'tx003',
          amount: 100000,
          currency: 'MMK',
          type: TransactionType.topUp,
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          status: 'Completed',
          description: 'Deposit via AYA Bank',
        ),
      ];

      state = state.copyWith(transactions: transactions, isLoading: false);
    } catch (e) {
      // Handle error
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> updateCurrency(String currency) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(preferredCurrency: currency);
    return true;
  }

  Future<Map<String, dynamic>> processTopUp({
    required String providerKey,
    required double amount,
    required String currency,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(paymentRepositoryProvider);
      final response = await repository.processTopUp(
        providerKey: providerKey,
        amount: amount,
        currency: currency,
      );

      state = state.copyWith(isLoading: false);
      return response;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> processWithdrawal({
    required String providerKey,
    required double amount,
    required String currency,
    required String accountNumber,
    String? remarks,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(paymentRepositoryProvider);
      final response = await repository.processWithdrawal(
        providerKey: providerKey,
        amount: amount,
        currency: currency,
        accountNumber: accountNumber,
        remarks: remarks,
      );

      state = state.copyWith(isLoading: false);
      return response;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> processDeposit({
    required int providerId,
    required int billingId,
    required String amount,
    required String accountNumber,
    required String transactionId,
    String? remark,
  }) async {
    print('Processing deposit with provider ID: $providerId');

    if (providerId <= 0) {
      throw Exception('Invalid provider ID: $providerId');
    }

    state = state.copyWith(isLoading: true);

    try {
      // Get user data from home provider
      final homeData = await ref.read(homeDataProvider.future);
      final user = homeData.user;

      final repository = ref.read(paymentRepositoryProvider);
      final response = await repository.storeDeposit(
        providerId: providerId,
        billingId: billingId,
        amount: amount,
        accountNumber: accountNumber,
        userName: user.username,
        transactionId: transactionId,
        userId: user.id,
        remark: remark,
      );

      state = state.copyWith(isLoading: false);
      return response; // Return the API response
    } catch (e) {
      print('Error in processDeposit: $e');
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> processStoreWithdraw({
    required int providerId,
    required int billingId,
    required String amount,
    required String accountNumber,
    String? transactionId,
    String? remark,
  }) async {
    print('Processing withdrawal with provider ID: $providerId');

    if (providerId <= 0) {
      throw Exception('Invalid provider ID: $providerId');
    }

    state = state.copyWith(isLoading: true);

    try {
      // Get user data from home provider
      final homeData = await ref.read(homeDataProvider.future);
      final user = homeData.user;

      final repository = ref.read(paymentRepositoryProvider);
      final response = await repository.storeWithdraw(
        providerId: providerId,
        billingId: billingId,
        amount: amount,
        accountNumber: accountNumber,
        userName: user.username,
        userId: user.id,
        transactionId: transactionId,
        remark: remark,
      );

      state = state.copyWith(isLoading: false);
      return response; // Return the API response
    } catch (e) {
      print('Error in processStoreWithdraw: $e');
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}

final paymentProvider =
    riverpod.StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
      return PaymentNotifier(ref);
    });
