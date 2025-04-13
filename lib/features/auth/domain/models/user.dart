class User {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final bool isVerified;
  final String? phoneNumber;
  final String? contactNumbers;
  final double? balance;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.isVerified = false,
    this.phoneNumber,
    this.contactNumbers,
    this.balance,
    this.createdAt,
  });

  // Create User from json
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? json['username'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      isVerified: json['is_verified'] ?? false,
      phoneNumber: json['phone_number'],
      contactNumbers: json['contact_numbers'],
      balance:
          json['balance'] != null ? (json['balance'] as num).toDouble() : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  // Convert User to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'is_verified': isVerified,
      'phone_number': phoneNumber,
      'contact_numbers': contactNumbers,
      'balance': balance,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Create copy of User with updated fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    bool? isVerified,
    String? phoneNumber,
    String? contactNumbers,
    double? balance,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      isVerified: isVerified ?? this.isVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      contactNumbers: contactNumbers ?? this.contactNumbers,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
