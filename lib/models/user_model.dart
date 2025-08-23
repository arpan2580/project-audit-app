class UserModel {
  final int id;
  final String name;
  final String? email;
  final String? mobile;
  final String agency;
  final String role;
  final String empCode;
  final bool isTest;
  final bool passForceReset;
  final String avatar;
  final DateTime dateJoined;
  final String twilioUserSid;
  final String twilioConversationSid;
  final Manager? manager;
  final dynamic managersUsers; // Keep dynamic if it's null or varying

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.mobile,
    required this.agency,
    required this.role,
    required this.empCode,
    required this.isTest,
    required this.passForceReset,
    required this.avatar,
    required this.dateJoined,
    required this.twilioUserSid,
    required this.twilioConversationSid,
    this.manager,
    this.managersUsers,
  });

  /// Convert JSON to Model
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'],
      mobile: json['mobile'],
      agency: json['agency'] ?? '',
      role: json['role'] ?? '',
      empCode: json['emp_code'] ?? '',
      isTest: json['is_test'] ?? false,
      passForceReset: json['pass_force_reset'] ?? false,
      avatar: json['avatar'] ?? '',
      dateJoined: DateTime.parse(json['date_joined']),
      twilioUserSid: json['twilio_user_sid'] ?? '',
      twilioConversationSid: json['twilio_conversation_sid'] ?? '',
      manager: json['manager'] != null
          ? Manager.fromJson(json['manager'])
          : null,
      managersUsers: json['managers_users'],
    );
  }

  /// Convert Model to JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "mobile": mobile,
      "agency": agency,
      "role": role,
      "emp_code": empCode,
      "is_test": isTest,
      "pass_force_reset": passForceReset,
      "avatar": avatar,
      "date_joined": dateJoined.toIso8601String(),
      "twilio_user_sid": twilioUserSid,
      "twilio_conversation_sid": twilioConversationSid,
      "manager": manager?.toJson(),
      "managers_users": managersUsers,
    };
  }
}

class Manager {
  final int id;
  final String name;
  final String agency;
  final String role;

  Manager({
    required this.id,
    required this.name,
    required this.agency,
    required this.role,
  });

  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      id: json['id'],
      name: json['name'] ?? '',
      agency: json['agency'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "agency": agency, "role": role};
  }
}
