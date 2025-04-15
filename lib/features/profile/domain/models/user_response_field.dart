class UserResponseField {
  String? id;
  String? response;
  String? responseType;
  String? createdAt;
  String? updatedAt;

  UserResponseField({
    this.id,
    this.response,
    this.responseType,
    this.createdAt,
    this.updatedAt,
  });

  UserResponseField.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    response = json['response'];
    responseType = json['response_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['response'] = response;
    data['response_type'] = responseType;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
