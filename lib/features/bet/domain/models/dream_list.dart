class DreamListResponse {
  List<Dreams>? dreams;

  DreamListResponse({this.dreams});

  DreamListResponse.fromJson(Map<String, dynamic> json) {
    if (json['dreams'] != null) {
      dreams = <Dreams>[];
      json['dreams'].forEach((v) {
        dreams!.add(Dreams.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (dreams != null) {
      data['dreams'] = dreams!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Dreams {
  String? name;
  String? url;
  String? number1;
  String? number2;

  Dreams({this.name, this.url, this.number1, this.number2});

  Dreams.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    url = json['url'];
    number1 = json['number1'];
    number2 = json['number2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['url'] = url;
    data['number1'] = number1;
    data['number2'] = number2;
    return data;
  }
}
