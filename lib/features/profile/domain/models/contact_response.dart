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
  ContactGroup? phone;
  ContactGroup? viber;
  ContactGroup? telegram;
  ContactGroup? facebook;
  List<ContactData>? tiktok;

  Contacts({this.phone, this.viber, this.telegram, this.facebook, this.tiktok});

  Contacts.fromJson(Map<String, dynamic> json) {
    phone = json['Phone'] != null ? ContactGroup.fromJson(json['Phone']) : null;
    viber = json['Viber'] != null ? ContactGroup.fromJson(json['Viber']) : null;
    telegram = json['Telegram'] != null ? ContactGroup.fromJson(json['Telegram']) : null;
    facebook = json['Facebook'] != null ? ContactGroup.fromJson(json['Facebook']) : null;
    
    if (json['TikTok'] != null) {
      tiktok = <ContactData>[];
      json['TikTok'].forEach((v) {
        tiktok!.add(ContactData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (phone != null) {
      data['Phone'] = phone!.toJson();
    }
    if (viber != null) {
      data['Viber'] = viber!.toJson();
    }
    if (telegram != null) {
      data['Telegram'] = telegram!.toJson();
    }
    if (facebook != null) {
      data['Facebook'] = facebook!.toJson();
    }
    if (tiktok != null) {
      data['TikTok'] = tiktok!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ContactGroup {
  List<ContactData>? data;
  String? icon;

  ContactGroup({this.data, this.icon});

  ContactGroup.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ContactData>[];
      json['data'].forEach((v) {
        data!.add(ContactData.fromJson(v));
      });
    }
    icon = json['icon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['icon'] = icon;
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
  String? createdAt;
  String? updatedAt;

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