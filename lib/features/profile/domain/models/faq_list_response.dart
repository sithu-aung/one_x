class FAQListResponse {
  List<Faq>? faq;

  FAQListResponse({this.faq});

  FAQListResponse.fromJson(Map<String, dynamic> json) {
    if (json['faq'] != null) {
      faq = <Faq>[];
      json['faq'].forEach((v) {
        faq!.add(Faq.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (faq != null) {
      data['faq'] = faq!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Faq {
  int? id;
  String? question;
  String? answer;

  Faq({this.id, this.question, this.answer});

  Faq.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    question = json['question'];
    answer = json['answer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['question'] = question;
    data['answer'] = answer;
    return data;
  }
}
