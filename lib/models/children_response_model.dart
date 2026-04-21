import 'package:fasolingo/models/child_model.dart';

class ChildrenResponseModel {
  final bool success;
  final int? total;
  final List<ChildModel> data;

  const ChildrenResponseModel({
    required this.success,
    required this.data,
    this.total,
  });

  factory ChildrenResponseModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    final list = <ChildModel>[];

    if (rawList is List) {
      for (final e in rawList) {
        if (e is Map<String, dynamic>) {
          list.add(ChildModel.fromJson(e));
        } else if (e is Map) {
          list.add(ChildModel.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }

    return ChildrenResponseModel(
      success: json['success'] == true,
      total: json['total'] is int ? json['total'] as int : int.tryParse('${json['total']}'),
      data: list,
    );
  }
}
