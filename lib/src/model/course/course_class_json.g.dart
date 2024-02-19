// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_class_json.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SemesterJson _$SemesterJsonFromJson(Map<String, dynamic> json) => SemesterJson(
      year: json['year'] as String?,
      semester: json['semester'] as String?,
    );

Map<String, dynamic> _$SemesterJsonToJson(SemesterJson instance) =>
    <String, dynamic>{
      'year': instance.year,
      'semester': instance.semester,
    };

ClassmateJson _$ClassmateJsonFromJson(Map<String, dynamic> json) =>
    ClassmateJson(
      studentName: json['studentName'] as String?,
      studentId: json['studentId'] as String?,
    )..departmentName = json['departmentName'] as String?;

Map<String, dynamic> _$ClassmateJsonToJson(ClassmateJson instance) =>
    <String, dynamic>{
      'departmentName': instance.departmentName,
      'studentName': instance.studentName,
      'studentId': instance.studentId,
    };
