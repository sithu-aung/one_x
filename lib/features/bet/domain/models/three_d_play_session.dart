class ThreeDPlaySession {
  List<ThreeDigits>? threeDigits;

  ThreeDPlaySession({this.threeDigits});

  ThreeDPlaySession.fromJson(Map<String, dynamic> json) {
    if (json['threeDigits'] != null) {
      threeDigits = <ThreeDigits>[];
      json['threeDigits'].forEach((v) {
        threeDigits!.add(ThreeDigits.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (threeDigits != null) {
      data['threeDigits'] = threeDigits!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ThreeDigits {
  int? id;
  String? permanentNumber;
  dynamic percentage;
  String? isTape;
  String? isHot;
  String? status;
  dynamic digitLimit;

  ThreeDigits({
    this.id,
    this.permanentNumber,
    this.percentage,
    this.isTape,
    this.isHot,
    this.status,
    this.digitLimit,
  });

  ThreeDigits.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    permanentNumber = json['permanent_number'];
    percentage = json['percentage'];
    isTape = json['is_tape'];
    isHot = json['is_hot'];
    status = json['status'];
    digitLimit = json['digit_limit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['permanent_number'] = permanentNumber;
    data['percentage'] = percentage;
    data['is_tape'] = isTape;
    data['is_hot'] = isHot;
    data['status'] = status;
    data['digit_limit'] = digitLimit;
    return data;
  }
}
