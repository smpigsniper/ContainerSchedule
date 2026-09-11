import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ContainerScheduleModel {
  final String salesName;
  final String containerSize;
  final DateTime date;
  final TimeOfDay time;
  final String loadingTime;
  final String transportType;
  final bool isAluminum;
  final bool isDimension;
  final String memo;

  ContainerScheduleModel({
    required this.salesName,
    required this.containerSize,
    required this.date,
    required this.time,
    required this.loadingTime,
    required this.transportType,
    required this.isAluminum,
    required this.isDimension,
    required this.memo,
  });

  factory ContainerScheduleModel.fromJson(Map<String, dynamic> json) {
    // 1. 解析 MM/dd/yyyy 日期格式
    final DateFormat dateFormat = DateFormat('MM/dd/yyyy');
    final DateTime parsedDate = dateFormat.parse(json['date'] as String);

    final timeParts = (json['time'] as String).split(':');
    final TimeOfDay parsedTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));

    return ContainerScheduleModel(
      salesName: json['salesName'] as String? ?? '',
      containerSize: json['containerSize'] as String? ?? '',
      date: parsedDate,
      time: parsedTime,
      loadingTime: json['loadingTime'] as String? ?? '',
      transportType: json['transportType'] as String? ?? '',
      isAluminum: json['isAluminum'] as bool? ?? false,
      isDimension: json['isDimension'] as bool? ?? false,
      memo: json['memo'] as String? ?? '',
    );
  }
}
