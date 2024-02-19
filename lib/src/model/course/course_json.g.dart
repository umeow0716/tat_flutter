// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_json.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Course _$CourseFromJson(Map<String, dynamic> json) => Course(
      studentId: json['studentId'] as String?,
      year: json['year'] as String?,
      sem: json['sem'] as String?,
      snum: json['snum'] as String?,
      code: json['code'] as String?,
      nameCN: json['nameCN'] as String?,
      nameEN: json['nameEN'] as String?,
      credits: json['credits'] as String?,
      hours: json['hours'] as String?,
      currCode: json['currCode'] as String?,
      teacherCN: json['teacherCN'] as String?,
      teacherEN: json['teacherEN'] as String?,
      teacherCode: json['teacherCode'] as String?,
      openClassCNList: (json['openClassCNList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      openClassENList: (json['openClassENList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      openClassCodeList: (json['openClassCodeList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      classroomCNList: (json['classroomCNList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      classroomCodeList: (json['classroomCodeList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      time: (json['time'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
    )
      ..mainCreateTimeStamp =
          DateTime.parse(json['mainCreateTimeStamp'] as String)
      ..hasExtraInfo = json['hasExtraInfo'] as bool
      ..extraCreateTimeStamp =
          DateTime.parse(json['extraCreateTimeStamp'] as String)
      ..courseYear = json['courseYear'] as String
      ..courseSem = json['courseSem'] as String
      ..classroomENList = (json['classroomENList'] as List<dynamic>)
          .map((e) => e as String)
          .toList()
      ..hasExtra = json['hasExtra'] as bool
      ..category = json['category'] as String
      ..classmateNum = json['classmateNum'] as String
      ..leaveNum = json['leaveNum'] as String
      ..classmateList = (json['classmateList'] as List<dynamic>)
          .map((e) => Map<String, String>.from(e as Map))
          .toList();

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
      'mainCreateTimeStamp': instance.mainCreateTimeStamp.toIso8601String(),
      'studentId': instance.studentId,
      'year': instance.year,
      'sem': instance.sem,
      'snum': instance.snum,
      'code': instance.code,
      'nameCN': instance.nameCN,
      'nameEN': instance.nameEN,
      'credits': instance.credits,
      'hours': instance.hours,
      'currCode': instance.currCode,
      'teacherCN': instance.teacherCN,
      'teacherEN': instance.teacherEN,
      'teacherCode': instance.teacherCode,
      'openClassCNList': instance.openClassCNList,
      'openClassENList': instance.openClassENList,
      'openClassCodeList': instance.openClassCodeList,
      'time': instance.time,
      'hasExtraInfo': instance.hasExtraInfo,
      'extraCreateTimeStamp': instance.extraCreateTimeStamp.toIso8601String(),
      'courseYear': instance.courseYear,
      'courseSem': instance.courseSem,
      'classroomCNList': instance.classroomCNList,
      'classroomENList': instance.classroomENList,
      'classroomCodeList': instance.classroomCodeList,
      'hasExtra': instance.hasExtra,
      'category': instance.category,
      'classmateNum': instance.classmateNum,
      'leaveNum': instance.leaveNum,
      'classmateList': instance.classmateList,
    };
