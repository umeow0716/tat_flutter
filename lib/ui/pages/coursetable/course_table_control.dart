import 'package:flutter/material.dart';
import 'package:flutter_app/src/config/app_colors.dart';
import 'package:flutter_app/src/model/course/course_json.dart';
import 'package:flutter_app/src/r.dart';

class CourseTableControl {
  bool isHideSaturday = false;
  bool isHideSunday = false;
  bool isHideUnKnown = true;
  bool isHideN = false;
  bool isHideA = false;
  bool isHideB = false;
  bool isHideC = false;
  bool isHideD = false;
  List<Course>? courseTable;
  List<String> dayStringList = [
    R.current.Monday,
    R.current.Tuesday,
    R.current.Wednesday,
    R.current.Thursday,
    R.current.Friday,
    R.current.Saturday,
    R.current.Sunday,
    R.current.UnKnown
  ];
  List<String> timeList = [
    "08:10 - 09:00",
    "09:10 - 10:00",
    "10:10 - 11:00",
    "11:10 - 12:00",
    "12:10 - 13:00",
    "13:10 - 14:00",
    "14:10 - 15:00",
    "15:10 - 16:00",
    "16:10 - 17:00",
    "17:10 - 18:00",
    "18:30 - 19:20",
    "19:20 - 20:10",
    "20:20 - 21:10",
    "21:10 - 22:00"
  ];

  List<String> sectionStringList = ["1", "2", "3", "4", "N", "5", "6", "7", "8", "9", "A", "B", "C", "D"];
  static int dayLength = 8;
  static int sectionLength = 14;
  Map<String, Color>? colorMap;

  void set(List<Course>? value) {
    courseTable = value;
    isHideSaturday = courseTable?.where((course) => course.time.containsKey('六')).isEmpty ?? true;
    isHideSunday = courseTable?.where((course) => course.time.containsKey('日')).isEmpty ?? true;
    isHideN = courseTable?.where((course) => course.time.values.where((ele) => ele.contains('N')).isNotEmpty).isEmpty ?? true;
    isHideA = courseTable?.where((course) => course.time.values.where((ele) => ele.contains('A')).isNotEmpty).isEmpty ?? true;
    isHideB = courseTable?.where((course) => course.time.values.where((ele) => ele.contains('B')).isNotEmpty).isEmpty ?? true;
    isHideC = courseTable?.where((course) => course.time.values.where((ele) => ele.contains('C')).isNotEmpty).isEmpty ?? true;
    isHideD = courseTable?.where((course) => course.time.values.where((ele) => ele.contains('D')).isNotEmpty).isEmpty ?? true;
    isHideA &= (isHideB & isHideC & isHideD);
    isHideB &= (isHideC & isHideD);
    isHideC &= isHideD;
    _initColorList();
  }

  List<int> get getDayIntList {
    List<int> intList = [];
    for (int i = 0; i < dayLength; i++) {
      if (isHideSaturday && i == 5) continue;
      if (isHideSunday && i == 6) continue;
      if (isHideUnKnown && i == 7) continue;
      intList.add(i);
    }
    return intList;
  }

  final dayList = ['一', '二', '三', '四', '五', '六', '日', null];
  final sectionList = ['1', '2', '3', '4', 'N', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D'];
  Course? getCourseInfo(int intDay, int intNumber) {
    final day = dayList[intDay];
    final section = sectionList[intNumber];

    if (courseTable == null) {
      return null;
    }

    final result = courseTable?.where((course) => course.time[day]?.contains(section) ?? false).toList();
    if(result == null || result.isEmpty) return null;

    return result.first;
  }

  Color? getCourseInfoColor(int intDay, int intNumber) {
    final course = getCourseInfo(intDay, intNumber);

    if (colorMap == null) {
      return Colors.white;
    }

    for (final key in colorMap!.keys) {
      if (course != null) {
        if (key == course.code) {
          return colorMap![key];
        }
      }
    }

    return Colors.white;
  }

  void _initColorList() {
    colorMap = {};
    List<String>? courseInfoList = courseTable?.map((course) => course.code).toList() ?? [];
    int colorCount = courseInfoList.length;

    colorCount = (colorCount == 0) ? 1 : colorCount;

    final colors = AppColors.courseTableColors.toList()..shuffle();

    for (int i = 0; i < colorCount; i++) {
      colorMap![courseInfoList[i]] = colors[i % colors.length];
    }
  }

  List<int> get getSectionIntList {
    List<int> intList = [];
    for (int i = 0; i < sectionLength; i++) {
      if (isHideN && i == 4) continue;
      if (isHideA && i == 10) continue;
      if (isHideB && i == 11) continue;
      if (isHideC && i == 12) continue;
      if (isHideD && i == 13) continue;
      intList.add(i);
    }
    return intList;
  }

  String getDayString(int day) {
    return dayStringList[day];
  }

  String getTimeString(int time) {
    return timeList[time];
  }

  String getSectionString(int section) {
    return sectionStringList[section];
  }
}
