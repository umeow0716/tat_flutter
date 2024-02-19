import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/model/course/course_class_json.dart';
import 'package:flutter_app/src/util/language_util.dart';
import 'package:json_annotation/json_annotation.dart';

part 'course_json.g.dart';

@JsonSerializable()
class Course {
  late DateTime mainCreateTimeStamp;

  String studentId = '';

  String year = '';
  String sem = '';

  String snum = ''; // use for ShowSyllabus.jsp query: snum, code
  String code = '';

  String nameCN = '';
  String nameEN = '';

  String credits = '';
  String hours = '';

  String currCode = ''; // use for Curr.jsp query: code
  
  String teacherCN = '';
  String teacherEN = '';
  String teacherCode = ''; // use for Teach.jsp query: code

  List<String> openClassCNList = [];
  List<String> openClassENList = [];
  List<String> openClassCodeList = []; //use for Subj.jsp query: code

  Map<String, List<String>> time = {};

  bool hasExtraInfo = false;

  late DateTime extraCreateTimeStamp;

  String courseYear = '';
  String courseSem = '';

  List<String> classroomCNList = [];
  List<String> classroomENList = [];
  List<String> classroomCodeList = [];
  
  bool hasExtra = false;

  String category = '';
  String classmateNum = '';
  String leaveNum = '';
  List<ClassmateJson> classmateList = [];

  Course({
    String? studentId,
    String? year,
    String? sem,
    String? snum,
    String? code,
    String? nameCN,
    String? nameEN,
    String? credits,
    String? hours,
    String? currCode,
    String? teacherCN,
    String? teacherEN,
    String? teacherCode,
    List<String>? openClassCNList,
    List<String>? openClassENList,
    List<String>? openClassCodeList,
    List<String>? classroomCNList,
    List<String>? classroomCodeList,
    Map<String, List<String>>? time,
  }) {
    this.studentId = studentId ?? this.studentId;
    this.year = year ?? this.year;
    this.sem = sem ?? this.sem;
    this.snum = snum ?? this.snum;
    this.code = code ?? this.code;
    this.nameCN = nameCN ?? this.nameCN;
    this.nameEN = nameEN ?? this.nameEN;
    this.credits = credits ?? this.credits;
    this.hours = hours ?? this.hours;
    this.currCode = currCode ?? this.currCode;
    this.teacherCN = teacherCN ?? this.teacherCN;
    this.teacherEN = teacherEN ?? this.teacherEN;
    this.teacherCode = teacherCode ?? this.teacherCode;
    this.openClassCNList = openClassCNList ?? this.openClassCNList;
    this.openClassENList = openClassENList ?? this.openClassENList;
    this.openClassCodeList = openClassCodeList ?? this.openClassCodeList;
    this.time = time ?? this.time;
    this.classroomCNList = classroomCNList ?? this.classroomCNList;
    this.classroomCodeList = classroomCodeList ?? this.classroomCodeList;

    mainCreateTimeStamp = DateTime.now();
  }

  bool setExtra({
    String? category,
    String? classmateNum,
    String? leaveNum,
    List<ClassmateJson>? classmateList
  }) {
    try {
      this.category = category ?? this.category;
      this.classmateNum = classmateNum ?? this.classmateNum;
      this.leaveNum = leaveNum ?? this.leaveNum;
      this.classmateList = classmateList ?? this.classmateList;
      
      hasExtra = true;
      return true;
    } catch(e, stack) {
      Log.eWithStack(e, stack);
      return false;
    }
  }

  String get name {
    return LanguageUtil.getLangIndex() == LangEnum.zh ? nameCN : nameEN;
  }

  String get openClass {
    return LanguageUtil.getLangIndex() == LangEnum.zh ? openClassCNList.join(' ') : openClassENList.join();
  }

  String get classroomRow {
    return LanguageUtil.getLangIndex() == LangEnum.zh ? classroomCNList.join(' ') : classroomENList.join(' ');
  }

  List<String> get classroomList {
    return LanguageUtil.getLangIndex() == LangEnum.zh ? classroomCNList : classroomENList;
  }

  String get teacher {
    return LanguageUtil.getLangIndex() == LangEnum.zh ? teacherCN : teacherEN;
  }

  bool get isEmpty {
    if(nameCN.isEmpty) { // 沒有名稱
      return true;
    }

    if(LanguageUtil.getLangIndex() == LangEnum.en && nameEN.isEmpty) {
      return true;
    }

    if(time.isEmpty) { // 沒有節數
      return true;
    }

    return false;
  }

  bool get isNotEmpty {
    return !isEmpty;
  }

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);

  Map<String, dynamic> toJson() => _$CourseToJson(this);
}