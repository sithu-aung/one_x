class ThreeDWinnerListResponse {
  List<Winners>? winners;

  ThreeDWinnerListResponse({this.winners});

  ThreeDWinnerListResponse.fromJson(Map<String, dynamic> json) {
    if (json['winners'] != null) {
      winners = <Winners>[];
      json['winners'].forEach((v) {
        winners!.add(Winners.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (winners != null) {
      data['winners'] = winners!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Winners {
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
  LotteryDigit? lotteryDigit;

  Winners({
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
    this.lotteryDigit,
  });

  Winners.fromJson(Map<String, dynamic> json) {
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
    lotteryDigit =
        json['lottery_digit'] != null
            ? LotteryDigit.fromJson(json['lottery_digit'])
            : null;
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
    if (lotteryDigit != null) {
      data['lottery_digit'] = lotteryDigit!.toJson();
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
  Null oddId;
  bool? status;
  int? balance;
  String? phone;
  Null referral;
  String? dateOfBirth;
  String? myReferral;
  String? hiddenPhone;
  Null email;
  Null profilePhoto;
  Null address;
  Null country;
  Null emailVerifiedAt;
  String? createdAt;
  String? updatedAt;
  int? digitUsage;
  String? createdAtHuman;

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
    return data;
  }
}

class LotteryDigit {
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

  LotteryDigit({
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

  LotteryDigit.fromJson(Map<String, dynamic> json) {
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
