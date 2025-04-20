class TransactionDetailResponse {
  Transaction? transaction;

  TransactionDetailResponse({this.transaction});

  TransactionDetailResponse.fromJson(Map<String, dynamic> json) {
    transaction =
        json['transaction'] != null
            ? Transaction.fromJson(json['transaction'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (transaction != null) {
      data['transaction'] = transaction!.toJson();
    }
    return data;
  }
}

class Transaction {
  int? id;
  String? transactionHistoryKey;
  int? senderId;
  dynamic actionBy;
  int? receiptId;
  int? providerId;
  int? billingId;
  int? lastBalance;
  int? newBalance;
  int? senderAmount;
  int? senderAccount;
  String? senderName;
  String? transactionType;
  String? transactionStatus;
  String? transactionId;
  String? remark;
  ReceiptUser? receiptUser;
  Provider? provider;

  Transaction({
    this.id,
    this.transactionHistoryKey,
    this.senderId,
    this.actionBy,
    this.receiptId,
    this.providerId,
    this.billingId,
    this.lastBalance,
    this.newBalance,
    this.senderAmount,
    this.senderAccount,
    this.senderName,
    this.transactionType,
    this.transactionStatus,
    this.transactionId,
    this.remark,
    this.receiptUser,
    this.provider,
  });

  Transaction.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    transactionHistoryKey = json['transaction_history_key'];
    senderId = json['sender_id'];
    actionBy = json['action_by'];
    receiptId = json['receipt_id'];
    providerId = json['provider_id'];
    billingId = json['billing_id'];
    lastBalance = json['last_balance'];
    newBalance = json['new_balance'];
    senderAmount = json['sender_amount'];
    senderAccount = json['sender_account'];
    senderName = json['sender_name'];
    transactionType = json['transaction_type'];
    transactionStatus = json['transaction_status'];
    transactionId = json['transaction_id'];
    remark = json['remark'];
    receiptUser =
        json['receipt_user'] != null
            ? ReceiptUser.fromJson(json['receipt_user'])
            : null;
    provider =
        json['provider'] != null ? Provider.fromJson(json['provider']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['transaction_history_key'] = transactionHistoryKey;
    data['sender_id'] = senderId;
    data['action_by'] = actionBy;
    data['receipt_id'] = receiptId;
    data['provider_id'] = providerId;
    data['billing_id'] = billingId;
    data['last_balance'] = lastBalance;
    data['new_balance'] = newBalance;
    data['sender_amount'] = senderAmount;
    data['sender_account'] = senderAccount;
    data['sender_name'] = senderName;
    data['transaction_type'] = transactionType;
    data['transaction_status'] = transactionStatus;
    data['transaction_id'] = transactionId;
    data['remark'] = remark;
    if (receiptUser != null) {
      data['receipt_user'] = receiptUser!.toJson();
    }
    if (provider != null) {
      data['provider'] = provider!.toJson();
    }
    return data;
  }
}

class ReceiptUser {
  int? id;
  String? userKey;
  String? username;
  String? userCode;
  int? agree;
  int? parentId;
  dynamic oddId;
  bool? status;
  int? balance;
  String? phone;
  dynamic referral;
  String? dateOfBirth;
  String? myReferral;
  String? hiddenPhone;
  String? email;
  dynamic profilePhoto;
  dynamic address;
  dynamic country;
  dynamic emailVerifiedAt;
  int? digitUsage;
  String? createdAtHuman;

  ReceiptUser({
    this.id,
    this.userKey,
    this.username,
    this.userCode,
    this.agree,
    this.parentId,
    this.oddId,
    this.status,
    this.balance,
    this.phone,
    this.referral,
    this.dateOfBirth,
    this.myReferral,
    this.hiddenPhone,
    this.email,
    this.profilePhoto,
    this.address,
    this.country,
    this.emailVerifiedAt,
    this.digitUsage,
    this.createdAtHuman,
  });

  ReceiptUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userKey = json['userKey'];
    username = json['username'];
    userCode = json['user_code'];
    agree = json['agree'];
    parentId = json['parent_id'];
    oddId = json['odd_id'];
    status = json['status'];
    balance = json['balance'];
    phone = json['phone'];
    referral = json['referral'];
    dateOfBirth = json['date_of_birth'];
    myReferral = json['my_referral'];
    hiddenPhone = json['hidden_phone'];
    email = json['email'];
    profilePhoto = json['profile_photo'];
    address = json['address'];
    country = json['country'];
    emailVerifiedAt = json['email_verified_at'];
    digitUsage = json['digit_usage'];
    createdAtHuman = json['created_at_human'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userKey'] = userKey;
    data['username'] = username;
    data['user_code'] = userCode;
    data['agree'] = agree;
    data['parent_id'] = parentId;
    data['odd_id'] = oddId;
    data['status'] = status;
    data['balance'] = balance;
    data['phone'] = phone;
    data['referral'] = referral;
    data['date_of_birth'] = dateOfBirth;
    data['my_referral'] = myReferral;
    data['hidden_phone'] = hiddenPhone;
    data['email'] = email;
    data['profile_photo'] = profilePhoto;
    data['address'] = address;
    data['country'] = country;
    data['email_verified_at'] = emailVerifiedAt;
    data['digit_usage'] = digitUsage;
    data['created_at_human'] = createdAtHuman;
    return data;
  }
}

class Provider {
  int? id;
  String? providerKey;
  int? userId;
  String? providerName;
  String? providerSlug;
  String? imageName;
  String? imagePath;
  String? imageLocation;
  ReceiptUser? user;

  Provider({
    this.id,
    this.providerKey,
    this.userId,
    this.providerName,
    this.providerSlug,
    this.imageName,
    this.imagePath,
    this.imageLocation,
    this.user,
  });

  Provider.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    providerKey = json['providerKey'];
    userId = json['user_id'];
    providerName = json['provider_name'];
    providerSlug = json['provider_slug'];
    imageName = json['image_name'];
    imagePath = json['image_path'];
    imageLocation = json['image_location'];
    user = json['user'] != null ? ReceiptUser.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['providerKey'] = providerKey;
    data['user_id'] = userId;
    data['provider_name'] = providerName;
    data['provider_slug'] = providerSlug;
    data['image_name'] = imageName;
    data['image_path'] = imagePath;
    data['image_location'] = imageLocation;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}
