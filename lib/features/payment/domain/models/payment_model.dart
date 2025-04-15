class BalanceModel {
  final double amount;
  final String currency;

  BalanceModel({required this.amount, required this.currency});

  factory BalanceModel.fromJson(Map<String, dynamic> json) {
    return BalanceModel(
      amount: json['amount'].toDouble(),
      currency: json['currency'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'amount': amount, 'currency': currency};
  }
}

class ExchangeRateModel {
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final DateTime updatedAt;

  ExchangeRateModel({
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.updatedAt,
  });

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRateModel(
      fromCurrency: json['from_currency'],
      toCurrency: json['to_currency'],
      rate: json['rate'].toDouble(),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from_currency': fromCurrency,
      'to_currency': toCurrency,
      'rate': rate,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class PaymentProviderModel {
  final int id;
  final String providerKey;
  final int userId;
  final String providerName;
  final String providerSlug;
  final String imageName;
  final String imagePath;
  final String imageLocation;
  final UserModel user;
  final Billing? billing;

  PaymentProviderModel({
    required this.id,
    required this.providerKey,
    required this.userId,
    required this.providerName,
    required this.providerSlug,
    required this.imageName,
    required this.imagePath,
    required this.imageLocation,
    required this.user,
    this.billing,
  });

  factory PaymentProviderModel.fromJson(Map<String, dynamic> json) {
    return PaymentProviderModel(
      id: json['id'],
      providerKey: json['providerKey'],
      userId: json['user_id'],
      providerName: json['provider_name'],
      providerSlug: json['provider_slug'],
      imageName: json['image_name'],
      imagePath: json['image_path'],
      imageLocation: json['image_location'],
      user: UserModel.fromJson(json['user']),
      billing:
          json['billing'] != null ? Billing.fromJson(json['billing']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providerKey': providerKey,
      'user_id': userId,
      'provider_name': providerName,
      'provider_slug': providerSlug,
      'image_name': imageName,
      'image_path': imagePath,
      'image_location': imageLocation,
      'user': user.toJson(),
      if (billing != null) 'billing': billing!.toJson(),
    };
  }
}

class UserModel {
  final int id;
  final String userKey;
  final String username;
  final String userCode;
  final int agree;
  final int parentId;
  final dynamic oddId;
  final bool status;
  final int balance;
  final String phone;
  final dynamic referral;
  final String dateOfBirth;
  final String myReferral;
  final String hiddenPhone;
  final String email;
  final dynamic profilePhoto;
  final dynamic address;
  final dynamic country;
  final dynamic emailVerifiedAt;
  final int digitUsage;
  final String createdAtHuman;

  UserModel({
    required this.id,
    required this.userKey,
    required this.username,
    required this.userCode,
    required this.agree,
    required this.parentId,
    this.oddId,
    required this.status,
    required this.balance,
    required this.phone,
    this.referral,
    required this.dateOfBirth,
    required this.myReferral,
    required this.hiddenPhone,
    required this.email,
    this.profilePhoto,
    this.address,
    this.country,
    this.emailVerifiedAt,
    required this.digitUsage,
    required this.createdAtHuman,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      userKey: json['userKey'],
      username: json['username'],
      userCode: json['user_code'],
      agree: json['agree'],
      parentId: json['parent_id'],
      oddId: json['odd_id'],
      status: json['status'],
      balance: json['balance'],
      phone: json['phone'],
      referral: json['referral'],
      dateOfBirth: json['date_of_birth'],
      myReferral: json['my_referral'],
      hiddenPhone: json['hidden_phone'],
      email: json['email'],
      profilePhoto: json['profile_photo'],
      address: json['address'],
      country: json['country'],
      emailVerifiedAt: json['email_verified_at'],
      digitUsage: json['digit_usage'],
      createdAtHuman: json['created_at_human'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userKey': userKey,
      'username': username,
      'user_code': userCode,
      'agree': agree,
      'parent_id': parentId,
      'odd_id': oddId,
      'status': status,
      'balance': balance,
      'phone': phone,
      'referral': referral,
      'date_of_birth': dateOfBirth,
      'my_referral': myReferral,
      'hidden_phone': hiddenPhone,
      'email': email,
      'profile_photo': profilePhoto,
      'address': address,
      'country': country,
      'email_verified_at': emailVerifiedAt,
      'digit_usage': digitUsage,
      'created_at_human': createdAtHuman,
    };
  }
}

class PaymentProvidersResponse {
  final List<PaymentProviderModel> providers;

  PaymentProvidersResponse({required this.providers});

  factory PaymentProvidersResponse.fromJson(Map<String, dynamic> json) {
    return PaymentProvidersResponse(
      providers:
          (json['providers'] as List)
              .map((provider) => PaymentProviderModel.fromJson(provider))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'providers': providers.map((provider) => provider.toJson()).toList(),
    };
  }
}

enum TransactionType { topUp, withdraw, payment, refund }

class TransactionModel {
  final String id;
  final double amount;
  final String currency;
  final TransactionType type;
  final String? description;
  final DateTime createdAt;
  final String status;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.type,
    this.description,
    required this.createdAt,
    required this.status,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      type: _parseTransactionType(json['type']),
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency,
      'type': type.toString().split('.').last,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }

  static TransactionType _parseTransactionType(String type) {
    switch (type) {
      case 'top_up':
        return TransactionType.topUp;
      case 'withdraw':
        return TransactionType.withdraw;
      case 'payment':
        return TransactionType.payment;
      case 'refund':
        return TransactionType.refund;
      default:
        return TransactionType.payment;
    }
  }
}

class Billing {
  final int id;
  final String billingKey;
  final int userId;
  final int providerId;
  final String providerName;
  final String providerPhone;
  final String status;

  Billing({
    required this.id,
    required this.billingKey,
    required this.userId,
    required this.providerId,
    required this.providerName,
    required this.providerPhone,
    required this.status,
  });

  factory Billing.fromJson(Map<String, dynamic> json) {
    return Billing(
      id: json['id'],
      billingKey: json['billingKey'],
      userId: json['user_id'],
      providerId: json['provider_id'],
      providerName: json['provider_name'],
      providerPhone: json['provider_phone'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'billingKey': billingKey,
      'user_id': userId,
      'provider_id': providerId,
      'provider_name': providerName,
      'provider_phone': providerPhone,
      'status': status,
    };
  }
}
