import 'dart:convert';

ChangePassModel changePassModelFromJson(String str) =>
    ChangePassModel.fromJson(json.decode(str));

String changePassModelToJson(ChangePassModel data) =>
    json.encode(data.toJson());

class ChangePassModel {
  ChangePassModel({required this.oldPass, required this.newPass});

  String oldPass, newPass;

  factory ChangePassModel.fromJson(Map<String, dynamic> json) =>
      ChangePassModel(
        oldPass: json["old_password"],
        newPass: json["new_password"],
      );

  Map<String, dynamic> toJson() => {
    "old_password": oldPass,
    "new_password": newPass,
  };
}
