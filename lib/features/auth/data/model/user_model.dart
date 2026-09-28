import 'package:entertainer/features/auth/domain/entities/user.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? json['full_name'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? json['phone_number'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
      };
}

extension UserModelX on UserModel {
  User toEntity() => User(
        id: id,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
}
