// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_main_extra_json.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseExtraInfoJson _$CourseExtraInfoJsonFromJson(Map<String, dynamic> json) {
  return CourseExtraInfoJson(
    courseSemester:
        SemesterJson.fromJson(json['courseSemester'] as Map<String, dynamic>),
    course: CourseExtraJson.fromJson(json['course'] as Map<String, dynamic>),
    classmate: (json['classmate'] as List)
        .map((e) => ClassmateJson.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$CourseExtraInfoJsonToJson(CourseExtraInfoJson instance) => <String, dynamic>{
      'courseSemester': instance.courseSemester,
      'course': instance.course,
      'classmate': instance.classmate,
    };

CourseMainInfoJson _$CourseMainInfoJsonFromJson(Map<String, dynamic> json) {
  return CourseMainInfoJson(
    course:CourseMainJson.fromJson(json['course'] as Map<String, dynamic>),
    teacher: (json['teacher'] as List)
        .map((e) => TeacherJson.fromJson(e as Map<String, dynamic>))
        .toList(),
    classroom: (json['classroom'] as List)
        .map((e) => ClassroomJson.fromJson(e as Map<String, dynamic>))
        .toList(),
    openClass: (json['openClass'] as List)
        .map((e) => ClassJson.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$CourseMainInfoJsonToJson(CourseMainInfoJson instance) => <String, dynamic>{
      'course': instance.course,
      'teacher': instance.teacher,
      'classroom': instance.classroom,
      'openClass': instance.openClass,
    };
