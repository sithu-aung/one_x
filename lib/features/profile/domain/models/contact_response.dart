class ContactResponse {
  Contacts? contacts;

  ContactResponse({this.contacts});

  ContactResponse.fromJson(Map<String, dynamic> json) {
    contacts =
        json['contacts'] != null ? Contacts.fromJson(json['contacts']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (contacts != null) {
      data['contacts'] = contacts!.toJson();
    }
    return data;
  }
}

class Contacts {
  List<ContactData>? phone;
  List<ContactData>? viber;
  List<ContactData>? facebook;
  List<ContactData>? whatsApp;

  Contacts({this.phone, this.viber, this.facebook});

  Contacts.fromJson(Map<String, dynamic> json) {
    if (json['Phone'] != null) {
      phone = <ContactData>[];
      json['Phone'].forEach((v) {
        phone!.add(ContactData.fromJson(v));
      });
    }
    if (json['Viber'] != null) {
      viber = <ContactData>[];
      json['Viber'].forEach((v) {
        viber!.add(ContactData.fromJson(v));
      });
    }
    if (json['Facebook'] != null) {
      facebook = <ContactData>[];
      json['Facebook'].forEach((v) {
        facebook!.add(ContactData.fromJson(v));
      });
    }
    if (json['WhatsApp'] != null) {
      whatsApp = <ContactData>[];
      json['WhatsApp'].forEach((v) {
        whatsApp!.add(ContactData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (phone != null) {
      data['Phone'] = phone!.map((v) => v.toJson()).toList();
    }
    if (viber != null) {
      data['Viber'] = viber!.map((v) => v.toJson()).toList();
    }
    if (facebook != null) {
      data['Facebook'] = facebook!.map((v) => v.toJson()).toList();
    }
    if (whatsApp != null) {
      data['WhatsApp'] = whatsApp!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ContactData {
  int? id;
  int? actionBy;
  int? categoryId;
  String? contact;
  String? createdAt;
  String? updatedAt;
  Category? category;

  ContactData({
    this.id,
    this.actionBy,
    this.categoryId,
    this.contact,
    this.createdAt,
    this.updatedAt,
    this.category,
  });

  ContactData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    actionBy = json['action_by'];
    categoryId = json['category_id'];
    contact = json['contact'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    category =
        json['category'] != null ? Category.fromJson(json['category']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['action_by'] = actionBy;
    data['category_id'] = categoryId;
    data['contact'] = contact;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (category != null) {
      data['category'] = category!.toJson();
    }
    return data;
  }
}

class Category {
  int? id;
  String? name;
  String? slug;
  String? imageLocation;
  Null createdAt;
  Null updatedAt;

  Category({
    this.id,
    this.name,
    this.slug,
    this.imageLocation,
    this.createdAt,
    this.updatedAt,
  });

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    imageLocation = json['image_location'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    data['image_location'] = imageLocation;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
