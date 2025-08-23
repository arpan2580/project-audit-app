import 'dart:convert';

DashboardModel dashboardModelFromJson(String str) =>
    DashboardModel.fromJson(json.decode(str));

String dashboardModelToJson(DashboardModel data) => json.encode(data.toJson());

class DashboardModel {
  DashboardModel({required this.email, required this.password});

  String email, password;

  factory DashboardModel.fromJson(Map<String, dynamic> json) =>
      DashboardModel(email: json["username"], password: json["password"]);

  Map<String, dynamic> toJson() => {"username": email, "password": password};
}
