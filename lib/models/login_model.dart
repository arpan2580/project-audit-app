import 'dart:convert';

LoginModel loginModelFromJson(String str) =>
    LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  LoginModel({required this.email, required this.password});

  String email, password;

  factory LoginModel.fromJson(Map<String, dynamic> json) =>
      LoginModel(email: json["username"], password: json["password"]);

  Map<String, dynamic> toJson() => {"username": email, "password": password};
}
