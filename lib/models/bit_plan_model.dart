class BitPlanModel {
  final int id;
  final String olName;
  final String olCode;
  final String agency;
  final String visitDays;
  final bool isActive;
  final bool isInBitPlan;
  final String? inBitVisitStatus;
  final int currentMonthPlanCount;
  final int currentMonthVisitCount;
  final LastVisit? lastVisit;
  final String? lastVisitDate;
  final List<Visit> todaysVisitList;

  BitPlanModel({
    required this.id,
    required this.olName,
    required this.olCode,
    required this.agency,
    required this.visitDays,
    required this.isActive,
    required this.isInBitPlan,
    this.inBitVisitStatus,
    required this.currentMonthPlanCount,
    required this.currentMonthVisitCount,
    this.lastVisit,
    this.lastVisitDate,
    required this.todaysVisitList,
  });

  factory BitPlanModel.fromJson(Map<String, dynamic> json) {
    return BitPlanModel(
      id: json['id'] ?? 0,
      olName: json['ol_name'] ?? '',
      olCode: json['ol_code'] ?? '',
      agency: json['agency'] ?? '',
      visitDays: json['visit_days'] ?? '',
      isActive: json['is_active'] ?? false,
      isInBitPlan: json['is_in_bit_plan'] ?? false,
      inBitVisitStatus: json['in_bit_visit_status'],
      currentMonthPlanCount: json['current_month_plan_count'] ?? 0,
      currentMonthVisitCount: json['current_month_visit_count'] ?? 0,
      lastVisit: json['last_visit'] != null
          ? LastVisit.fromJson(json['last_visit'])
          : null,
      lastVisitDate: json['last_visit_date'],
      todaysVisitList:
          (json['todays_visit_list'] as List<dynamic>?)
              ?.map((e) => Visit.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "ol_name": olName,
      "ol_code": olCode,
      "agency": agency,
      "visit_days": visitDays,
      "is_active": isActive,
      "is_in_bit_plan": isInBitPlan,
      "in_bit_visit_status": inBitVisitStatus,
      "current_month_plan_count": currentMonthPlanCount,
      "current_month_visit_count": currentMonthVisitCount,
      "last_visit": lastVisit?.toJson(),
      "last_visit_date": lastVisitDate,
      'todays_visit_list': todaysVisitList.map((e) => e.toJson()).toList(),
    };
  }

  /// Helper method to parse a list of outlets from JSON
  static List<BitPlanModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => BitPlanModel.fromJson(json)).toList();
  }
}

class LastVisit {
  final int id;
  final String date;
  final String? startTime;
  final String? endTime;
  final String? duration;
  final String? photo;
  final double lat;
  final double long;
  final String status;
  final String outletAgency;

  LastVisit({
    required this.id,
    required this.date,
    this.startTime,
    this.endTime,
    this.duration,
    this.photo,
    required this.lat,
    required this.long,
    required this.status,
    required this.outletAgency,
  });

  factory LastVisit.fromJson(Map<String, dynamic> json) {
    return LastVisit(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      startTime: json['start_time'],
      endTime: json['end_time'],
      duration: json['duration'],
      photo: json['photo'],
      lat: json['start_latitude'],
      long: json['start_longitude'],
      status: json['status'] ?? '',
      outletAgency: json['outlet_agency'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "date": date,
      "start_time": startTime,
      "end_time": endTime,
      "duration": duration,
      "photo": photo,
      "start_latitude": lat,
      "start_longitude": long,
      "status": status,
      "outlet_agency": outletAgency,
    };
  }
}

class Visit {
  final int id;
  final String userName;
  final String date;
  final String? startTime;
  final String? endTime;
  final double? startLatitude;
  final double? startLongitude;
  final String? duration;
  final String? photo;
  final String status;
  final String outletAgency;

  Visit({
    required this.id,
    required this.userName,
    required this.date,
    this.startTime,
    this.endTime,
    this.startLatitude,
    this.startLongitude,
    this.duration,
    this.photo,
    required this.status,
    required this.outletAgency,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'],
      userName: json['user_name'],
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      startLatitude: (json['start_latitude'] as num?)?.toDouble(),
      startLongitude: (json['start_longitude'] as num?)?.toDouble(),
      duration: json['duration'],
      photo: json['photo'],
      status: json['status'],
      outletAgency: json['outlet_agency'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'start_latitude': startLatitude,
      'start_longitude': startLongitude,
      'duration': duration,
      'photo': photo,
      'status': status,
      'outlet_agency': outletAgency,
    };
  }
}
