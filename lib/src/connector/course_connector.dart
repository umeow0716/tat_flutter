import 'package:dio/dio.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/connector/core/connector.dart';
import 'package:flutter_app/src/connector/core/connector_parameter.dart';
import 'package:flutter_app/src/connector/ntut_connector.dart';
import 'package:flutter_app/src/model/course/course_class_json.dart';
import 'package:flutter_app/src/model/course/course_json.dart';
import 'package:flutter_app/src/model/course/course_score_json.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/src/util/language_util.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:flutter_app/src/connector/ischool_plus_connector.dart';

enum CourseConnectorStatus { loginSuccess, loginFail, unknownError }

class CourseConnector {
  static const _ssoLoginUrl = "${NTUTConnector.host}ssoIndex.do";
  static const String _courseCNHost = "https://aps.ntut.edu.tw/course/tw/";
  static const String _courseENHost = "https://aps.ntut.edu.tw/course/en/";
  static const String _postCourseCNUrl = "${_courseCNHost}Select.jsp";
  static const String _creditUrl = "${_courseCNHost}Cprog.jsp";
  static const String _coutseInfoCNUrl = "${_courseCNHost}ShowSyllabus.jsp";
  static const String _coutseInfoENUrl = "${_courseENHost}ShowSyllabus.jsp";

  static const String _loginDataUrl = "${_courseCNHost}courseSIE.jsp";

  static Future<CourseConnectorStatus> login() async {
    final ssoHtml = await loginSSO();
    if(ssoHtml == null) return CourseConnectorStatus.unknownError;

    final ssoInputs = ssoHtml.getElementsByTagName("input");

    final jumpUrl = ssoHtml.getElementsByTagName("form")[0].attributes["action"];
    if(jumpUrl == null) return CourseConnectorStatus.loginFail;

    final parameter = ConnectorParameter(jumpUrl);
    // ignore: prefer_for_elements_to_map_fromiterable
    parameter.data = Map<String, String>.fromIterable(ssoInputs,
      key: (e) => e.attributes['name'],
      value: (e) => e.attributes['value'],
    );

    await Connector.getDataByGetResponse(parameter);
    return CourseConnectorStatus.loginSuccess;
  }

  static Future<Document?> loginSSO() async {
    try {
      final parameter = ConnectorParameter(_ssoLoginUrl);
      parameter.data = {
        "apUrl": _loginDataUrl,
        "apOu": "aa_0010-",
        "sso": "true",
        "datetime1": DateTime.now().microsecondsSinceEpoch.toString(),
      };

      final responseBody = await Connector.getDataByGet(parameter);
      return parse(responseBody);
    } catch(e, stack) {
      Log.eWithStack(e, stack);
      return null;
    }
  }

  static Future<String?> getCourseENName(String url) async {
    try {
      ConnectorParameter parameter;
      Document tagNode;
      Element node;
      parameter = ConnectorParameter(url);
      parameter.charsetName = 'big5';
      String result = await Connector.getDataByGet(parameter);
      tagNode = parse(result);
      node = tagNode.getElementsByTagName("table").first;
      node = node.getElementsByTagName("tr")[1];
      return node.getElementsByTagName("td")[2].text.replaceAll(RegExp(r"\n"), "");
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<List<SemesterJson>?> getCourseSemester(String studentId) async {
    try {
      ConnectorParameter parameter;
      Document tagNode;
      Element node;
      List<Element> nodes;

      Map<String, String> data = {
        "code": studentId,
        "format": "-3",
      };
      parameter = ConnectorParameter(_postCourseCNUrl);
      parameter.data = data;
      Response response = await Connector.getDataByPostResponse(parameter);
      tagNode = parse(response.toString());
      node = tagNode.getElementsByTagName("table")[0];
      nodes = node.getElementsByTagName("tr");
      List<SemesterJson> semesterJsonList = [];
      for (int i = 1; i < nodes.length; i++) {
        node = nodes[i];
        String year, semester;
        year = node.getElementsByTagName("a")[0].text.split(" ")[0];
        semester = node.getElementsByTagName("a")[0].text.split(" ")[2];
        semesterJsonList.add(SemesterJson(year: year, semester: semester));
      }
      return semesterJsonList;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static String strQ2B(String input) {
    List<int> newString = [];
    for (int c in input.codeUnits) {
      if (c == 12288) {
        c = 32;
        continue;
      }
      if (c > 65280 && c < 65375) {
        c = (c - 65248);
      }
      newString.add(c);
    }
    return String.fromCharCodes(newString);
  }

  static Future<List<Course>> getCourseList(String? year, String? sem) async {
    if(year == null || sem == null) return [];

    final studentId = LocalStorage.instance.getAccount();

    try {
      final lang = LanguageUtil.getLangIndex();
      List<Course> result = [];

      final parameter = ConnectorParameter(_postCourseCNUrl);
      parameter.data = {
        'code': studentId,
        'format': '-2',
        'year': year,
        'sem': sem,
      };

      final responseBody = await Connector.getDataByPost(parameter);
      final html = parse(responseBody);

      final courseTable = html.getElementsByTagName('table')[1];
      final courseElementList = courseTable.getElementsByTagName('tr');

      for(int i = 1 ; i < courseElementList.length-1 ; i++) {
        final course = courseParser(courseElementList[i], studentId, year, sem);
        if(course == null) continue;

        if(lang == LangEnum.en) await setENProfile(course);
        result.add(course);
      }

      return result;
    } catch(e, stack) {
      Log.eWithStack(e, stack);
      return [];
    }
  }

  static Course? courseParser(Element element, String? studentId, String? year, String? sem) {
    final data = {};
    try {
      final tdList = element.getElementsByTagName('td');

      final courseNameElement = tdList[1].getElementsByTagName('a')[0];
      final currUri = Uri.parse('$_courseCNHost${courseNameElement.attributes['href']}');
      data['nameCN'] = courseNameElement.innerHtml.trim();
      data['currCode'] = currUri.queryParameters['code'].toString().trim();

      try {
        final creditsElement = tdList[3];
        data['credits'] = creditsElement.innerHtml.trim();
      } catch(e, stack) {
        Log.eWithStack(e, stack);
      }

      try {
        final hoursElement = tdList[4];
        data['hours'] = hoursElement.innerHtml.trim();
      } catch(e, stack) {
        Log.eWithStack(e, stack);
      }

      try {
        final teacherElement = tdList[6].getElementsByTagName('a')[0];
        final teachUri = Uri.parse('$_courseCNHost${teacherElement.attributes['href']}');
        data['teacherCN'] = teacherElement.innerHtml;
        data['teacherCode'] = teachUri.queryParameters['code'];
      } catch(e, stack) {
        Log.eWithStack(e, stack);
      }

      try {
        final openClassCNList = <String>[];
        final openClassCodeList = <String>[];
        for(final classElement in tdList[7].getElementsByTagName('a')) {
          final classUri = Uri.parse('$_courseCNHost${classElement.attributes['href']}');
          openClassCNList.add(classElement.innerHtml.trim());
          openClassCodeList.add(classUri.queryParameters['code'] ?? '');
        }
        data['openClassCNList'] = openClassCNList;
        data['openClassCodeList'] = openClassCodeList;
      } catch(e, stack) {
        Log.eWithStack(e, stack);
      }

      try {
        data['classroomCNList'] = <String>[];
        data['classroomCodeList'] = <String>[];
        final classroomElements = tdList[15].getElementsByTagName('a');
        for(final element in classroomElements) {
          final classroomUri = Uri.parse('$_courseCNHost${element.attributes['href']}');
          data['classroomCNList'].add(element.innerHtml.trim());
          data['classroomCodeList'].add(classroomUri.queryParameters['code']);
        }
      } catch(e, stack) {
        Log.eWithStack(e, stack);
      }

      try {
        final searchElement = tdList[18].getElementsByTagName('a')[0];
        final searchUri = Uri.parse('$_courseCNHost${searchElement.attributes['href']}');
        data['snum'] = searchUri.queryParameters['snum'];
        data['code'] = searchUri.queryParameters['code'];
      } catch(e, stack) {
        Log.eWithStack(e, stack);
      }

      data['time'] = <String, List<String>>{};
      final dayEnum = [ '日', '一', '二', '三', '四', '五', '六' ];
      for(int i = 8 ; i < 15 ; i++) {
        if(tdList[i].innerHtml.trim().isNotEmpty) {
          data['time'][ dayEnum[i-8] ] = tdList[i].innerHtml.trim().split(' ');
        }
      }

      return Course(
        studentId: studentId,
        year: year,
        sem: sem,
        snum: data['snum'],
        code: data['code'],
        nameCN: data['nameCN'],
        credits: data['credits'],
        hours: data['hours'],
        currCode: data['currCode'],
        teacherCN: data['teacherCN'],
        teacherCode: data['teacherCode'],
        openClassCNList: data['openClassCNList'],
        openClassCodeList: data['openClassCodeList'],
        classroomCNList: data['classroomCNList'],
        classroomCodeList: data['classroomCodeList'],
        time: data['time'],
      );
    } catch(e, stack) {
      Log.eWithStack(e, stack);
      return null;
    }
  }

  static Course getWithOnlyName(Map data, List<Element> tdList, Element courseNameElement) {
    final dayEnum = [ '日', '一', '二', '三', '四', '五', '六' ];
    for(int i = 8 ; i < 15 ; i++) {
      if(tdList[i].innerHtml.trim().isNotEmpty) {
        data['time'][ dayEnum[i-8] ] = tdList[i].innerHtml.trim().split(' ');
      }
    }

    return Course(
      nameCN: courseNameElement.innerHtml.trim(),
      time: data['time'],
    );
  }

  static Future<void> setENProfile(Course course) async {
    final parameter = ConnectorParameter(_coutseInfoENUrl);
    parameter.data = {
      'snum': course.snum,
      'code': course.code,
    };
    final responseBody = await Connector.getDataByGet(parameter);
    final html = parse(responseBody);

    final infoTable = html.getElementsByTagName('table')[0];
    final tdList = infoTable.getElementsByTagName('tr')[1].getElementsByTagName('td');

    course.nameEN = tdList[2].innerHtml.trim();
    course.teacherEN = tdList[7].innerHtml.trim();
    course.openClassENList = tdList[8].innerHtml.trim().split('\n');
    course.classroomENList = tdList[8].innerHtml.trim().split('\n');
  }

  static Future<Map?> getGraduation(String year, String department) async {
    ConnectorParameter parameter;
    String result;
    Document tagNode;
    Element node;
    List<Element> nodes;
    RegExp exp;
    RegExpMatch matches;
    Map graduationMap = {};
    try {
      parameter = ConnectorParameter("https://aps.ntut.edu.tw/course/tw/Cprog.jsp");
      parameter.data = {"format": "-3", "year": year, "matric": "7"};
      result = await Connector.getDataByGet(parameter);
      tagNode = parse(result);
      node = tagNode.getElementsByTagName("tbody").first;
      nodes = node.getElementsByTagName("tr");
      String? href;
      for (int i = 1; i < nodes.length; i++) {
        node = nodes[i];
        node = node.getElementsByTagName("a").first;
        if (node.text.contains(department)) {
          href = node.attributes["href"]!;
          break;
        }
      }
      href = "https://aps.ntut.edu.tw/course/tw/${href!}";
      parameter = ConnectorParameter(href);
      result = await Connector.getDataByGet(parameter);

      exp = RegExp(r"最低畢業學分：?(\d+)學分");
      matches = exp.firstMatch(result)!;
      graduationMap["lowCredit"] = int.parse(matches.group(1)!);

      exp = RegExp(r"共同必修：?(\d+)學分");
      matches = exp.firstMatch(result)!;
      graduationMap["△"] = int.parse(matches.group(1)!);

      exp = RegExp(r"專業必修：?(\d+)學分");
      matches = exp.firstMatch(result)!;
      graduationMap["▲"] = int.parse(matches.group(1)!);

      exp = RegExp(r"專業選修：?(\d+)學分");
      matches = exp.firstMatch(result)!;
      graduationMap["★"] = int.parse(matches.group(1)!);

      /*
      exp = RegExp("通識博雅課程應修滿(\d+)學分");
      matches = exp.firstMatch(result);
      exp = RegExp("跨系所專業選修(\d+)學分為畢業學分");
      matches = exp.firstMatch(result);
      */
      return graduationMap;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<List<String>?> getYearList() async {
    ConnectorParameter parameter;
    String result;
    Document tagNode;
    Element node;
    List<Element> nodes;
    List<String> resultList = [];
    try {
      parameter = ConnectorParameter("https://aps.ntut.edu.tw/course/tw/Cprog.jsp");
      parameter.data = {"format": "-1"};
      result = await Connector.getDataByPost(parameter);
      tagNode = parse(result);
      nodes = tagNode.getElementsByTagName("a");
      for (int i = 0; i < nodes.length; i++) {
        node = nodes[i];
        resultList.add(node.text);
      }
      return resultList;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  /*
  Map Key
  name 名稱
  code 參數
  */
  static Future<List<Map>?> getDivisionList(String year) async {
    ConnectorParameter parameter;
    String result;
    Document tagNode;
    Element node;
    List<Element> nodes;
    List<Map> resultList = [];
    try {
      parameter = ConnectorParameter(_creditUrl);
      parameter.data = {"format": "-2", "year": year};
      result = await Connector.getDataByPost(parameter);
      tagNode = parse(result);
      nodes = tagNode.getElementsByTagName("a");
      for (int i = 0; i < nodes.length; i++) {
        node = nodes[i];
        Map<String, String> code = Uri.parse(node.attributes["href"]!).queryParameters;
        resultList.add({"name": node.text, "code": code});
      }
      return resultList;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  /*
  Map Key
  name 名稱
  code 參數
  */
  static Future<List<Map>?> getDepartmentList(Map code) async {
    ConnectorParameter parameter;
    String result;
    Document tagNode;
    Element node;
    List<Element> nodes;
    List<Map> resultList = [];
    try {
      parameter = ConnectorParameter(_creditUrl);
      parameter.data = code;
      result = await Connector.getDataByPost(parameter);
      tagNode = parse(result);
      node = tagNode.getElementsByTagName("table").first;
      nodes = node.getElementsByTagName("a");
      for (int i = 0; i < nodes.length; i++) {
        node = nodes[i];
        Map<String, String> code = Uri.parse(node.attributes["href"]!).queryParameters;
        String name = node.text.replaceAll(RegExp("[ |s]"), "");
        resultList.add({"name": name, "code": code});
      }
      return resultList;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  /*
  Map Key
  minGraduationCredits
  */
  static Future<GraduationInformationJson?> getCreditInfo(Map code, String select) async {
    ConnectorParameter parameter;
    String result;
    Document tagNode;
    Element anode, trNode, node, tdNode;
    List<Element> trNodes, tdNodes;
    GraduationInformationJson graduationInformation = GraduationInformationJson();
    try {
      Log.d("select is $select");
      parameter = ConnectorParameter(_creditUrl);
      parameter.data = code;
      result = await Connector.getDataByPost(parameter);
      tagNode = parse(result);
      node = tagNode.getElementsByTagName("table").first;
      trNodes = node.getElementsByTagName("tr");
      trNodes.removeAt(0);
      bool pass = false;
      for (int i = 0; i < trNodes.length; i++) {
        trNode = trNodes[i];
        anode = trNode.getElementsByTagName("a").first;
        String name = anode.text.replaceAll(RegExp("[ |s]"), "");
        if (name.contains(select)) {
          tdNodes = trNode.getElementsByTagName("td");
          Log.d(trNode.innerHtml);
          for (int j = 1; j < tdNodes.length; j++) {
            tdNode = tdNodes[j];
            /*
              "○", //	  必	部訂共同必修
              "△", //	必	校訂共同必修
              "☆", //	選	共同選修
              "●", //	  必	部訂專業必修
              "▲", //	  必	校訂專業必修
              "★" //	  選	專業選修
             */
            String creditString = tdNode.text.replaceAll(RegExp(r"[\s|\n]"), "");
            switch (j - 1) {
              case 0:
                graduationInformation.courseTypeMinCredit!["○"] = int.parse(creditString);
                break;
              case 1:
                graduationInformation.courseTypeMinCredit!["△"] = int.parse(creditString);
                break;
              case 2:
                graduationInformation.courseTypeMinCredit!["☆"] = int.parse(creditString);
                break;
              case 3:
                graduationInformation.courseTypeMinCredit!["●"] = int.parse(creditString);
                break;
              case 4:
                graduationInformation.courseTypeMinCredit!["▲"] = int.parse(creditString);
                break;
              case 5:
                graduationInformation.courseTypeMinCredit!["★"] = int.parse(creditString);
                break;
              case 6:
                graduationInformation.outerDepartmentMaxCredit = int.parse(creditString);
                break;
              case 7:
                graduationInformation.lowCredit = int.parse(creditString);
                break;
            }
          }
          pass = true;
          Log.d(graduationInformation.courseTypeMinCredit.toString());
          break;
        }
      }
      if (!pass) {
        Log.d("not find $select");
      }
      return graduationInformation;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<bool> getCourseExtraInfo(Course course) async {
    try {
      final parameter = ConnectorParameter(_coutseInfoCNUrl);
      parameter.data = {
        "snum": course.snum
      };

      final response = await Connector.getDataByGet(parameter);
      final tagNode = parse(response);
      final courseNodes = tagNode.getElementsByTagName("td");

      final category = courseNodes[6].innerHtml.trim();
      final classmateNum = courseNodes[9].innerHtml.trim();
      final leaveNum = courseNodes[10].innerHtml.trim();

      final classmateList = await ISchoolPlusConnector.getCourseClasmateList(course.snum);

      if(LanguageUtil.getLangIndex() == LangEnum.en) {

      }

      course.setExtra(
        category: category,
        classmateNum: classmateNum,
        leaveNum: leaveNum,
        classmateList: classmateList,
      );

      return course.hasExtra;
    } catch(e, stack) {
      Log.eWithStack(e, stack);
      return false;
    }
  }

  static Future<Map<String, String>?> getCourseCategoryInfo(String courseId) async {
    try {
      Map<String, String> result = <String, String>{
        'courseId': courseId
      };
      ConnectorParameter parameter;
      String response;
      Document tagNode;
      List<Element> courseNodes;
      Map<String, String> data = {
        "snum": courseId,
      };
      parameter = ConnectorParameter(_coutseInfoCNUrl);
      parameter.data = data;

      response = await Connector.getDataByGet(parameter);

      tagNode = parse(response);
      courseNodes = tagNode.getElementsByTagName("td");

      result['category'] = courseNodes[6].innerHtml.trim();
      result['openClass'] = courseNodes[8].innerHtml.trim();

      return {
        "courseId": courseId,
        "category": result["category"] ?? '',
        "openClass": result["openClass"] ?? '',
      };
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return {
        "courseId": courseId,
        "category": '',
        "openClass": ''
      };
    }
  }
}
