class TapeHotListResponse {
  List<TapeHot>? isTape;
  List<TapeHot>? isHot;

  TapeHotListResponse({this.isTape, this.isHot});

  TapeHotListResponse.fromJson(Map<String, dynamic> json) {
    if (json['is_tape'] != null) {
      isTape = <TapeHot>[];
      json['is_tape'].forEach((v) {
        isTape!.add(TapeHot.fromJson(v));
      });
    }
    if (json['is_hot'] != null) {
      isHot = <TapeHot>[];
      json['is_hot'].forEach((v) {
        isHot!.add(TapeHot.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (isTape != null) {
      data['is_tape'] = isTape!.map((v) => v.toJson()).toList();
    }
    if (isHot != null) {
      data['is_hot'] = isHot!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TapeHot {
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

  TapeHot({
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

  TapeHot.fromJson(Map<String, dynamic> json) {
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
