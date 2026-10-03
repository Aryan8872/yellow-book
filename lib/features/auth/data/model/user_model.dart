import 'package:entertainer/features/auth/domain/entities/user.dart';

class UserModel {
  final String? id;
  final String email;
  final String name;
  final String phone;
  final String? password;

  const UserModel({
    this.id,
    required this.email,
    required this.name,
    required this.phone,
    this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ??
          json['phoneNumber'] as String? ??
          json['phone_number'] as String? ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'email': email,
      'name': name,
      'phone': phone,
    };
    if (id != null && id!.isNotEmpty) {
      map['id'] = id;
    }
    if (password != null && password!.isNotEmpty) {
      map['password'] = password;
    }
    return map;
  }
}

extension UserModelX on UserModel {
  User toEntity() =>
      User(id: id ?? '', email: email, name: name, phone: phone);
}
