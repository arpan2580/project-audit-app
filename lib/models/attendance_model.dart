class AttendanceModel {
  final int id;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final bool isLate;
  final bool isGpsValid;
  final String? distanceFromOffice;
  final String status;
  final String? attnImage;

  AttendanceModel({
    required this.id,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    required this.isLate,
    required this.isGpsValid,
    this.distanceFromOffice,
    required this.status,
    this.attnImage,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] ?? 0,
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      checkInTime: json['check_in_time'] != null
          ? DateTime.parse(json['check_in_time'])
          : null,
      checkOutTime: json['check_out_time'] != null
          ? DateTime.parse(json['check_out_time'])
          : null,
      isLate: json['is_late'] ?? false,
      isGpsValid: json['is_gps_valid'] ?? false,
      distanceFromOffice: json['distance_from_office'] != null
          ? (json['distance_from_office'])
          : null,
      status: json['status'] ?? '',
      attnImage: json['attn_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "date": date,
      "check_in_time": checkInTime,
      "check_out_time": checkOutTime,
      "is_late": isLate,
      "is_gps_valid": isGpsValid,
      "distance_from_office": distanceFromOffice,
      "status": status,
      "attn_image": attnImage,
    };
  }

  /// Helper method to parse a list of attendance records from JSON
  static List<AttendanceModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => AttendanceModel.fromJson(json)).toList();
  }
}
