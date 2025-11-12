import 'package:intl/intl.dart';
import 'package:jnk_app/controllers/base_controller.dart';

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
  final Visit? myVisit;

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
    this.myVisit,
  });

  factory BitPlanModel.fromJson(
    Map<String, dynamic> json, {
    required int loggedInUserId,
  }) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final todaysVisits =
        (json['todays_visit_list'] as List?)
            ?.map((e) => Visit.fromJson(e))
            .toList() ??
        [];

    Visit? ownVisit;
    try {
      ownVisit = todaysVisits.firstWhere(
        (v) =>
            v.userId == loggedInUserId &&
            v.date == today &&
            v.endTime == null &&
            v.status.toLowerCase() == 'started',
      );

      BaseController.storeToken.write('currentAudit', ownVisit);
      BaseController.isAuditStarted.value = true;
      BaseController.currAuditOutletId.value = json['id'] ?? 0;
      BaseController.currAuditOutletName.value = json['ol_name'];
      BaseController.startTime.value = ownVisit.startTime ?? '';
      BaseController.latitude.value = ownVisit.startLatitude?.toString() ?? '';
      BaseController.longitude.value =
          ownVisit.startLongitude?.toString() ?? '';
      BaseController.auditorName.value = ownVisit.userName;
    } catch (e) {
      ownVisit = null;
    }

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
      todaysVisitList: todaysVisits,
      myVisit: ownVisit,
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

  // Helper method to parse a list of outlets from JSON
  static List<BitPlanModel> fromJsonList(
    List<dynamic> jsonList, {
    required int loggedInUserId,
  }) {
    return jsonList
        .map(
          (json) => BitPlanModel.fromJson(json, loggedInUserId: loggedInUserId),
        )
        .toList();
  }
}

class LastVisit {
  final int id;
  final int visitUserId;
  final String userName;
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
    required this.visitUserId,
    required this.userName,
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
      visitUserId: json['user_id'] ?? 0,
      userName: json['user_name'],
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
      "user_id": visitUserId,
      "user_name": userName,
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
  final int userId;
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
    required this.userId,
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
      userId: json['user_id'] ?? 0,
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
      'user_id': userId,
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
