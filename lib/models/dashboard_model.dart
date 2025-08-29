class DashboardModel {
  final AttendanceInfo? attendanceInfo;
  final LunchBreakInfo? lunchBreakInfo;
  final DailyCount? dailyCount;
  final MonthlyCount? monthlyCount;

  DashboardModel({
    this.attendanceInfo,
    this.lunchBreakInfo,
    this.dailyCount,
    this.monthlyCount,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      attendanceInfo: json['attendance_info'] != null
          ? AttendanceInfo.fromJson(json['attendance_info'])
          : null,
      lunchBreakInfo: json['lunch_break_info'] != null
          ? LunchBreakInfo.fromJson(json['lunch_break_info'])
          : null,
      dailyCount: json['daily_count'] != null
          ? DailyCount.fromJson(json['daily_count'])
          : null,
      monthlyCount: json['monthly_count'] != null
          ? MonthlyCount.fromJson(json['monthly_count'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "attendance_info": attendanceInfo?.toJson(),
      "lunch_break_info": lunchBreakInfo?.toJson(),
      "daily_count": dailyCount?.toJson(),
      "monthly_count": monthlyCount?.toJson(),
    };
  }
}

class AttendanceInfo {
  final String? status;
  final DateTime? checkInTime;
  final bool isLate;
  final bool isGpsValid;
  final double? distanceFromOffice;

  AttendanceInfo({
    this.status,
    this.checkInTime,
    required this.isLate,
    required this.isGpsValid,
    this.distanceFromOffice,
  });

  factory AttendanceInfo.fromJson(Map<String, dynamic> json) {
    return AttendanceInfo(
      status: json['status'],
      checkInTime: json['check_in_time'] != null
          ? DateTime.parse(json['check_in_time'])
          : null,
      isLate: json['is_late'] ?? false,
      isGpsValid: json['is_gps_valid'] ?? false,
      distanceFromOffice: json['distance_from_office'] != null
          ? (json['distance_from_office'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "check_in_time": checkInTime,
      "is_late": isLate,
      "is_gps_valid": isGpsValid,
      "distance_from_office": distanceFromOffice,
    };
  }
}

class LunchBreakInfo {
  final DateTime? startTime;
  final DateTime? endTime;
  final String? breakDuration;

  LunchBreakInfo({this.startTime, this.endTime, this.breakDuration});

  factory LunchBreakInfo.fromJson(Map<String, dynamic> json) {
    return LunchBreakInfo(
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'])
          : null,
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'])
          : null,
      breakDuration: json['break_duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "start_time": startTime,
      "end_time": endTime,
      "break_duration": breakDuration,
    };
  }
}

class DailyCount {
  final int planCount;
  final int achieveCount;

  DailyCount({required this.planCount, required this.achieveCount});

  factory DailyCount.fromJson(Map<String, dynamic> json) {
    return DailyCount(
      planCount: json['plan_count'] ?? 0,
      achieveCount: json['achieve_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {"plan_count": planCount, "achieve_count": achieveCount};
  }
}

class MonthlyCount {
  final int planCount;
  final int achieveCount;

  MonthlyCount({required this.planCount, required this.achieveCount});

  factory MonthlyCount.fromJson(Map<String, dynamic> json) {
    return MonthlyCount(
      planCount: json['plan_count'] ?? 0,
      achieveCount: json['achieve_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {"plan_count": planCount, "achieve_count": achieveCount};
  }
}
