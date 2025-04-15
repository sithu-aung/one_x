class WinningRecordListResponse {
  List<WinningRecord>? winningRecord;
  TwoOdd? twoOdd;
  TwoOdd? threeOdd;

  WinningRecordListResponse({this.winningRecord, this.twoOdd, this.threeOdd});

  WinningRecordListResponse.fromJson(Map<String, dynamic> json) {
    if (json['winning_record'] != null) {
      winningRecord = <WinningRecord>[];
      json['winning_record'].forEach((v) {
        winningRecord!.add(WinningRecord.fromJson(v));
      });
    }
    twoOdd = json['two_odd'] != null ? TwoOdd.fromJson(json['two_odd']) : null;
    threeOdd =
        json['three_odd'] != null ? TwoOdd.fromJson(json['three_odd']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (winningRecord != null) {
      data['winning_record'] = winningRecord!.map((v) => v.toJson()).toList();
    }
    if (twoOdd != null) {
      data['two_odd'] = twoOdd!.toJson();
    }
    if (threeOdd != null) {
      data['three_odd'] = threeOdd!.toJson();
    }
    return data;
  }
}

class WinningRecord {
  int? id;
  int? userId;
  int? lotteryId;
  int? lotteryDigitId;
  String? winnerNumber;
  String? prize;
  int? odd;
  String? type;
  String? amount;
  String? prizeAmount;
  String? status;
  String? createdAt;
  String? updatedAt;
  User? user;
  Lottery? lottery;

  WinningRecord({
    this.id,
    this.userId,
    this.lotteryId,
    this.lotteryDigitId,
    this.winnerNumber,
    this.prize,
    this.odd,
    this.type,
    this.amount,
    this.prizeAmount,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.lottery,
  });

  WinningRecord.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    lotteryId = json['lottery_id'];
    lotteryDigitId = json['lottery_digit_id'];
    winnerNumber = json['winner_number'];
    prize = json['prize'];
    odd = json['odd'];
    type = json['type'];
    amount = json['amount'];
    prizeAmount = json['prize_amount'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    lottery =
        json['lottery'] != null ? Lottery.fromJson(json['lottery']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['lottery_id'] = lotteryId;
    data['lottery_digit_id'] = lotteryDigitId;
    data['winner_number'] = winnerNumber;
    data['prize'] = prize;
    data['odd'] = odd;
    data['type'] = type;
    data['amount'] = amount;
    data['prize_amount'] = prizeAmount;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (lottery != null) {
      data['lottery'] = lottery!.toJson();
    }
    return data;
  }
}

class User {
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
  dynamic email;
  dynamic profilePhoto;
  dynamic address;
  dynamic country;
  dynamic emailVerifiedAt;
  String? createdAt;
  String? updatedAt;
  int? digitUsage;
  String? createdAtHuman;
  List<Rates>? rates;

  User({
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
    this.createdAt,
    this.updatedAt,
    this.digitUsage,
    this.createdAtHuman,
    this.rates,
  });

  User.fromJson(Map<String, dynamic> json) {
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
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    digitUsage = json['digit_usage'];
    createdAtHuman = json['created_at_human'];
    if (json['rates'] != null) {
      rates = <Rates>[];
      json['rates'].forEach((v) {
        rates!.add(Rates.fromJson(v));
      });
    }
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
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['digit_usage'] = digitUsage;
    data['created_at_human'] = createdAtHuman;
    if (rates != null) {
      data['rates'] = rates!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Rates {
  int? id;
  int? userId;
  String? role;
  String? type;
  int? commissionId;
  String? createdAt;
  String? updatedAt;
  Commission? commission;

  Rates({
    this.id,
    this.userId,
    this.role,
    this.type,
    this.commissionId,
    this.createdAt,
    this.updatedAt,
    this.commission,
  });

  Rates.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    role = json['role'];
    type = json['type'];
    commissionId = json['commission_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    commission =
        json['commission'] != null
            ? Commission.fromJson(json['commission'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['role'] = role;
    data['type'] = type;
    data['commission_id'] = commissionId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (commission != null) {
      data['commission'] = commission!.toJson();
    }
    return data;
  }
}

class Commission {
  int? id;
  String? commissionKey;
  String? commissionRate;
  String? createdAt;
  String? updatedAt;

  Commission({
    this.id,
    this.commissionKey,
    this.commissionRate,
    this.createdAt,
    this.updatedAt,
  });

  Commission.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    commissionKey = json['commissionKey'];
    commissionRate = json['commission_rate'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['commissionKey'] = commissionKey;
    data['commission_rate'] = commissionRate;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Lottery {
  int? id;
  int? payAmount;
  int? totalAmount;
  int? userId;
  int? lotteryMatchId;
  String? session;
  String? commission;
  String? commissionAmount;
  String? name;
  String? status;
  String? createdAt;
  String? updatedAt;
  Invoice? invoice;
  List<LotteryDigits>? lotteryDigits;

  Lottery({
    this.id,
    this.payAmount,
    this.totalAmount,
    this.userId,
    this.lotteryMatchId,
    this.session,
    this.commission,
    this.commissionAmount,
    this.name,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.invoice,
    this.lotteryDigits,
  });

  Lottery.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    payAmount = json['pay_amount'];
    totalAmount = json['total_amount'];
    userId = json['user_id'];
    lotteryMatchId = json['lottery_match_id'];
    session = json['session'];
    commission = json['commission'];
    commissionAmount = json['commission_amount'];
    name = json['name'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    invoice =
        json['invoice'] != null ? Invoice.fromJson(json['invoice']) : null;
    if (json['lottery_digits'] != null) {
      lotteryDigits = <LotteryDigits>[];
      json['lottery_digits'].forEach((v) {
        lotteryDigits!.add(LotteryDigits.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['pay_amount'] = payAmount;
    data['total_amount'] = totalAmount;
    data['user_id'] = userId;
    data['lottery_match_id'] = lotteryMatchId;
    data['session'] = session;
    data['commission'] = commission;
    data['commission_amount'] = commissionAmount;
    data['name'] = name;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (invoice != null) {
      data['invoice'] = invoice!.toJson();
    }
    if (lotteryDigits != null) {
      data['lottery_digits'] = lotteryDigits!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Invoice {
  int? id;
  String? invoiceKey;
  String? invoiceNumber;
  int? userId;
  int? lotteryId;
  String? amount;
  String? status;
  String? paymentMethod;
  String? name;
  dynamic taxAmount;
  dynamic discountAmount;
  String? createdAt;
  String? updatedAt;
  User? user;
  Lottery? lottery;

  Invoice({
    this.id,
    this.invoiceKey,
    this.invoiceNumber,
    this.userId,
    this.lotteryId,
    this.amount,
    this.status,
    this.paymentMethod,
    this.name,
    this.taxAmount,
    this.discountAmount,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.lottery,
  });

  Invoice.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    invoiceKey = json['invoiceKey'];
    invoiceNumber = json['invoice_number'];
    userId = json['user_id'];
    lotteryId = json['lottery_id'];
    amount = json['amount'];
    status = json['status'];
    paymentMethod = json['payment_method'];
    name = json['name'];
    taxAmount = json['tax_amount'];
    discountAmount = json['discount_amount'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    lottery =
        json['lottery'] != null ? Lottery.fromJson(json['lottery']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['invoiceKey'] = invoiceKey;
    data['invoice_number'] = invoiceNumber;
    data['user_id'] = userId;
    data['lottery_id'] = lotteryId;
    data['amount'] = amount;
    data['status'] = status;
    data['payment_method'] = paymentMethod;
    data['name'] = name;
    data['tax_amount'] = taxAmount;
    data['discount_amount'] = discountAmount;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (lottery != null) {
      data['lottery'] = lottery!.toJson();
    }
    return data;
  }
}

class LotteryDigits {
  int? id;
  int? userId;
  int? lotteryId;
  int? permanentNumberId;
  int? subAmount;
  int? prizeSent;
  String? status;
  String? createdAt;
  String? updatedAt;
  PermanentNumber? permanentNumber;

  LotteryDigits({
    this.id,
    this.userId,
    this.lotteryId,
    this.permanentNumberId,
    this.subAmount,
    this.prizeSent,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.permanentNumber,
  });

  LotteryDigits.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    lotteryId = json['lottery_id'];
    permanentNumberId = json['permanent_number_id'];
    subAmount = json['sub_amount'];
    prizeSent = json['prize_sent'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    permanentNumber =
        json['permanent_number'] != null
            ? PermanentNumber.fromJson(json['permanent_number'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['lottery_id'] = lotteryId;
    data['permanent_number_id'] = permanentNumberId;
    data['sub_amount'] = subAmount;
    data['prize_sent'] = prizeSent;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (permanentNumber != null) {
      data['permanent_number'] = permanentNumber!.toJson();
    }
    return data;
  }
}

class PermanentNumber {
  String? permanentKey;
  int? id;
  String? permanentNumber;
  String? name;
  String? digitLimit;
  String? status;
  String? isTape;
  String? isHot;
  String? createdAt;
  String? updatedAt;

  PermanentNumber({
    this.permanentKey,
    this.id,
    this.permanentNumber,
    this.name,
    this.digitLimit,
    this.status,
    this.isTape,
    this.isHot,
    this.createdAt,
    this.updatedAt,
  });

  PermanentNumber.fromJson(Map<String, dynamic> json) {
    permanentKey = json['permanentKey'];
    id = json['id'];
    permanentNumber = json['permanent_number'];
    name = json['name'];
    digitLimit = json['digit_limit'];
    status = json['status'];
    isTape = json['is_tape'];
    isHot = json['is_hot'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['permanentKey'] = permanentKey;
    data['id'] = id;
    data['permanent_number'] = permanentNumber;
    data['name'] = name;
    data['digit_limit'] = digitLimit;
    data['status'] = status;
    data['is_tape'] = isTape;
    data['is_hot'] = isHot;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class TwoOdd {
  int? id;
  int? userId;
  String? odd;
  String? comOdd;
  String? hotLimit;
  String? type;
  String? createdAt;
  String? updatedAt;

  TwoOdd({
    this.id,
    this.userId,
    this.odd,
    this.comOdd,
    this.hotLimit,
    this.type,
    this.createdAt,
    this.updatedAt,
  });

  TwoOdd.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    odd = json['odd'];
    comOdd = json['com_odd'];
    hotLimit = json['hot_limit'];
    type = json['type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['odd'] = odd;
    data['com_odd'] = comOdd;
    data['hot_limit'] = hotLimit;
    data['type'] = type;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
