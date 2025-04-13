class PolicyResponse {
  Policy? policy;

  PolicyResponse({this.policy});

  PolicyResponse.fromJson(Map<String, dynamic> json) {
    policy = json['policy'] != null ? Policy.fromJson(json['policy']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (policy != null) {
      data['policy'] = policy!.toJson();
    }
    return data;
  }
}

class Policy {
  int? id;
  String? description;
  String? type;
  String? createdAt;
  String? updatedAt;

  Policy({
    this.id,
    this.description,
    this.type,
    this.createdAt,
    this.updatedAt,
  });

  Policy.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    description = json['description'];
    type = json['type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['description'] = description;
    data['type'] = type;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
