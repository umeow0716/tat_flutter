import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/connector/core/dio_connector.dart';
import 'package:flutter_app/src/model/course/course_json.dart';
import 'package:flutter_app/src/model/course/course_score_json.dart';
import 'package:flutter_app/src/model/setting/setting_json.dart';
import 'package:flutter_app/src/model/userdata/user_data_json.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage._();

  factory LocalStorage() => _instance;
  static final _instance = LocalStorage._();

  static LocalStorage get instance => _instance;

  static const courseNotice = "CourseNotice";
  static const appCheckUpdate = "AppCheckUpdate";

  final cacheManager = DefaultCacheManager();

  final _userDataJsonKey = "UserDataJsonKey";
  final _courseSemesterJsonKey = "CourseSemesterListJson";
  final _scoreCreditJsonKey = "ScoreCreditJsonKey";
  final _settingJsonKey = "SettingJsonKey";
  final _courseTableSettingJsonKey = "CourseTableSettingJson";
  final _coursesKey = "CoursesJson";
  final _firstRun = <String, bool>{};

  final _httpClientInterceptors = <Interceptor>[];

  SharedPreferences? _pref;
  UserDataJson? _userData;
  CourseScoreCreditJson? _courseScoreList;
  SettingJson? _setting;
  List<Map<String, String>?>? _courseSemesterList = [];
  List<Course> courses = [];
  Map<String, String?> _courseTableSetting = {};

  bool? get autoCheckAppUpdate => _setting?.other?.autoCheckAppUpdate;

  String getStudentNameFromCourse(String? studentId) {
    if(studentId == null) return '';

    if(studentId == getAccount()) return getUserInfo()?.givenName ?? '';

    final result = courses
      .where((course) => course.studentId == studentId)
      .where((course) => course.studentName.isNotEmpty)
      .map((course) => course.studentName)
      .firstOrNull ?? '';
    return result;
  }

  List<String> getStudentIdListFromCourse() {
    final result = courses
      .map((course) => course.studentId)
      .where((studentId) => studentId.isNotEmpty)
      .toSet()
      .toList();
    return result;
  }

  void addCourse(Course? course, { bool save = true}) {
    if(course == null || course.isEmpty) return;

    courses.removeWhere((ele) => ele.code == course.code && ele.snum == course.snum && ele.currCode == course.currCode);
    courses.add(course);

    if(save) _save(_coursesKey, courses);
  }

  void addAllCourse(List<Course>? courseList) {
    if(courseList == null || courseList.isEmpty) return;
    
    for(final course in courseList) {
      addCourse(course, save: false);
    }

    _save(_coursesKey, courses);
  }

  void _loadCourses() {
    final readJson = _readStringList(_coursesKey);
    if(readJson == null) return;

    courses = readJson.map((e) => 
      Course.fromJson(
        json.decode(e)
      )).toList();
  }

  bool? getFirstUse(String key, {int? timeOut}) {
    if (timeOut != null) {
      final millsTimeOut = timeOut * 1000;
      final wKey = "firstUse$key";
      final now = DateTime.now().millisecondsSinceEpoch;
      final before = _readInt(wKey);

      if (before != null && before > now) {
        return false;
      }

      _writeInt(wKey, now + millsTimeOut);
    }

    if (!_firstRun.containsKey(key)) {
      _firstRun[key] = true;
    }

    return _firstRun[key];
  }

  void setAlreadyUse(String key) => _firstRun[key] = false;

  void _setFirstUse(String key, bool value) => _firstRun[key] = value;

  Future<void> saveUserData() => _save(_userDataJsonKey, _userData);

  Future<void> clearUserData() {
    _userData = UserDataJson();
    return saveUserData();
  }

  void _loadUserData() {
    final readJson = _readString(_userDataJsonKey);
    _userData = (readJson != null) ? UserDataJson.fromJson(json.decode(readJson)) : UserDataJson();
  }

  void _loadCourseTableSetting() {
    final readJson = _readString(_courseTableSettingJsonKey);
    _courseTableSetting = Map.castFrom(json.decode(readJson ?? '{}'));
  }

  void setAccount(String account) => _userData?.account = account;

  String? getAccount() => _userData?.account;

  void setPassword(String password) => _userData?.password = password;

  String? getPassword() => _userData?.password;

  void setUserInfo(UserInfoJson value) => _userData?.info = value;

  UserInfoJson? getUserInfo() => _userData?.info;

  UserDataJson? getUserData() => _userData;

  String? getCourseNameByCourseId(String courseId) {
    final name = courses.where((course) => course.snum == courseId).firstOrNull?.name;
    return name;
  }

  Future<void> _saveSetting() => _save(_settingJsonKey, _setting);

  void _loadSetting() {
    final readJson = _readString(_settingJsonKey);
    _setting = (readJson != null) ? SettingJson.fromJson(json.decode(readJson)) : SettingJson();
  }

  Future<void> saveCourseScoreCredit() => _save(_scoreCreditJsonKey, _courseScoreList);

  List<SemesterCourseScoreJson>? getSemesterCourseScore() => _courseScoreList?.semesterCourseScoreList;

  GraduationInformationJson? getGraduationInformation() => _courseScoreList?.graduationInformation;

  CourseScoreCreditJson? getCourseScoreCredit() => _courseScoreList;

  Future<void> _clearCourseScoreCredit() {
    _courseScoreList = CourseScoreCreditJson();
    return saveCourseScoreCredit();
  }

  Future<void> setCourseScoreCredit(CourseScoreCreditJson? value) {
    _courseScoreList = value;
    return saveCourseScoreCredit();
  }

  Future<void> setSemesterCourseScore(List<SemesterCourseScoreJson> value) {
    _courseScoreList?.graduationInformation = GraduationInformationJson();
    _courseScoreList?.semesterCourseScoreList = value;
    return saveCourseScoreCredit();
  }

  void _loadCourseScoreCredit() {
    final readJson = _readString(_scoreCreditJsonKey);
    _courseScoreList =
        (readJson != null) ? CourseScoreCreditJson.fromJson(json.decode(readJson)) : CourseScoreCreditJson();
  }

  Future<void> saveCourseSetting() async {
    await _saveSetting();
  } 

  Map<String, String?> getCourseTableSetting () => _courseTableSetting;

  Future<void> saveCourseTableSetting() async {
    await _save(_courseTableSettingJsonKey, _courseTableSetting);
  }

  Future<void> saveOtherSetting() => _saveSetting();

  void setOtherSetting(OtherSettingJson value) => _setting?.other = value;

  OtherSettingJson? getOtherSetting() => _setting?.other;

  Future<void> _saveAnnouncementSetting() => _saveSetting();

  Future<void> _clearAnnouncementSetting() {
    _setting?.announcement = AnnouncementSettingJson();
    return _saveAnnouncementSetting();
  }

  void clearSemesterJsonList() => _courseSemesterList?.clear();

  void _loadSemesterJsonList() {
    final readJsonList = _readStringList(_courseSemesterJsonKey);
    _courseSemesterList?.clear();

    if (readJsonList != null) {
      for (final readJson in readJsonList) {
        _courseSemesterList?.add(json.decode(readJson));
      }
    }
  }

  void setSemesterJsonList(List<Map<String, String>?>? value) => _courseSemesterList = value;

  Map<String, String>? getSemesterJsonItem(int index) =>
      ((_courseSemesterList?.length ?? -1) > index) ? _courseSemesterList![index] : null;

  List<Map<String, String>?>? getSemesterList() => _courseSemesterList;

  String? getVersion() => _readString("version");

  Future<void> setVersion(String version) => _writeString("version", version);

  Future<void> init({List<Interceptor> httpClientInterceptors = const []}) async {
    _pref = await SharedPreferences.getInstance();
    await DioConnector.instance.init(interceptors: httpClientInterceptors);
    _httpClientInterceptors.addAll(httpClientInterceptors);
    _courseSemesterList = _courseSemesterList;
    _loadUserData();
    _loadCourseTableSetting();
    _loadSetting();
    _loadCourseScoreCredit();
    _loadSemesterJsonList();
    _loadCourses();
  }

  Future<void> logout() async {
    await clearUserData();
    clearSemesterJsonList();
    await _clearCourseScoreCredit();
    await _clearAnnouncementSetting();
    await cacheManager.emptyCache();
    _setFirstUse(courseNotice, true);
    await init();
  }

  Future<void> _save(String key, dynamic saveObj) async {
    try {
      await _saveJsonList(key, saveObj);
    } catch (e) {
      await _saveJson(key, saveObj);
    }
  }

  Future<void> _saveJson(String key, dynamic saveObj) => _writeString(key, json.encode(saveObj));

  Future<void> _saveJsonList(String key, dynamic saveObj) async {
    final jsonList = <String>[];

    for (dynamic obj in saveObj) {
      jsonList.add(json.encode(obj));
    }

    await _writeStringList(key, jsonList);
  }

  Future<void> _writeString(String key, String value) async {
    await _pref?.setString(key, value);
  }

  Future<void> _writeInt(String key, int value) async {
    await _pref?.setInt(key, value);
  }

  int? _readInt(String key) => _pref?.getInt(key);

  Future<void> _writeStringList(String key, List<String> value) async {
    try {
      await _pref?.setStringList(key, value);
    } catch(err, stack) {
      Log.eWithStack(err, stack);
    }
  }

  String? _readString(String key) {
    try {
      return _pref?.getString(key);
    } catch(err, stack) {
      Log.eWithStack(err, stack);
      return null;
    }
  }

  List<String>? _readStringList(String key) => _pref?.getStringList(key);
}
