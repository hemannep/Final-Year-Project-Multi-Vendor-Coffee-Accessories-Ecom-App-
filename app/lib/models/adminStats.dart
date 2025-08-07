class AdminStatResponse {
  bool? success;
  String? message;
  List<AdminStat>? stats;

  AdminStatResponse({this.success, this.message, this.stats});

  AdminStatResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['stats'] != null) {
      stats = <AdminStat>[];
      json['stats'].forEach((v) {
        stats!.add(AdminStat.fromJson(v));
      });
    }
  }
}

class AdminStat {
  String? title;
  String? value;
  int? change;
  String? subtitle;

  AdminStat({this.title, this.value, this.change, this.subtitle});

  AdminStat.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    value = json['value'].toString();
    change = json['change'];
    subtitle = json['subtitle'];
  }
}