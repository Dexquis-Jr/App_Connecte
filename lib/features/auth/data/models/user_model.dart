import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({required super.id, required super.email});

  factory UserModel.fromEmail(String email) {
    // reqres.in doesn't return a user id on login, so we derive a stable
    // local id from the email. A real backend would return a proper id
    // (and full profile) in the auth response.
    return UserModel(id: email.hashCode.toString(), email: email);
  }

  Map<String, dynamic> toJson() => {'id': id, 'email': email};

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel(id: json['id'] as String, email: json['email'] as String);
}
