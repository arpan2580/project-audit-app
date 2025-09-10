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
  final List<Agent>? managersUsers; // Keep dynamic if it's null or varying
  final List<Agent>? adminUsers;

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
    this.adminUsers,
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
      managersUsers: json['managers_users'] != null
          ? List<Agent>.from(
              json['managers_users'].map((user) => Agent.fromJson(user)),
            )
          : null,
      adminUsers: json['admin_users'] != null
          ? List<Agent>.from(
              json['admin_users'].map((user) => Agent.fromJson(user)),
            )
          : null,
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
      "managers_users": managersUsers?.map((user) => user.toJson()).toList(),
      "admin_users": adminUsers?.map((user) => user.toJson()).toList(),
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

class Agent {
  final int id;
  final String name;
  final String agency;
  final String role;
  final String empCode;
  final String avatar;
  final String twilioUserSid;
  final String twilioConversationSid;

  Agent({
    required this.id,
    required this.name,
    required this.agency,
    required this.role,
    required this.empCode,
    required this.avatar,
    required this.twilioUserSid,
    required this.twilioConversationSid,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      agency: json['agency'] ?? '',
      role: json['role'] ?? '',
      empCode: json['emp_code'] ?? '',
      avatar: json['avatar'] ?? '',
      twilioUserSid: json['twilio_user_sid'] ?? '',
      twilioConversationSid: json['twilio_conversation_sid'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "agency": agency,
      "role": role,
      "emp_code": empCode,
      "avatar": avatar,
      "twilio_user_sid": twilioUserSid,
      "twilio_conversation_sid": twilioConversationSid,
    };
  }

  /// Helper method to parse a list of attendance records from JSON
  // static List<Agent> fromJsonList(List<dynamic> jsonList) {
  //   return jsonList.map((json) => Agent.fromJson(json)).toList();
  // }
}
