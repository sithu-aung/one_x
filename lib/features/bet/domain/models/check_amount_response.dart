class CheckAmountResponse {
  String? information;
  List<Selections>? selections;
  int? betAmount;
  int? totalBetAmount;

  CheckAmountResponse({
    this.information,
    this.selections,
    this.betAmount,
    this.totalBetAmount,
  });

  CheckAmountResponse.fromJson(Map<String, dynamic> json) {
    information = json['information'];
    if (json['selections'] != null) {
      selections = <Selections>[];
      json['selections'].forEach((v) {
        selections!.add(Selections.fromJson(v));
      });
    }
    betAmount = json['betAmount'];
    totalBetAmount = json['totalBetAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['information'] = information;
    if (selections != null) {
      data['selections'] = selections!.map((v) => v.toJson()).toList();
    }
    data['betAmount'] = betAmount;
    data['totalBetAmount'] = totalBetAmount;
    return data;
  }
}

class Selections {
  String? permanentNumber;
  int? amount;
  String? isTape;
  String? isHot;

  Selections({this.permanentNumber, this.amount, this.isTape, this.isHot});

  Selections.fromJson(Map<String, dynamic> json) {
    permanentNumber = json['permanent_number'];
    amount = json['amount'];
    isTape = json['is_tape'];
    isHot = json['is_hot'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['permanent_number'] = permanentNumber;
    data['amount'] = amount;
    data['is_tape'] = isTape;
    data['is_hot'] = isHot;
    return data;
  }
}
