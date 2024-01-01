// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'dart:developer' as developer;

import 'package:flutter_app/src/model/coursetable/course_table_json.dart';
import 'package:flutter_app/src/model/json_init.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sprintf/sprintf.dart';
import 'package:flutter_app/src/util/language_util.dart';
import 'package:flutter_app/src/r.dart';

part 'course_class_json.g.dart';

@JsonSerializable()
class CourseMainJson {
  String name;
  String id;
  String href;
  String note; //備註
  String stage; //階段
  String credits; //學分
  String hours; //時數
  String scheduleHref; // 教學進度大綱
  Map<Day, String> time; //時間

  CourseMainJson(
      {this.name, this.href, this.id, this.credits, this.hours, this.stage, this.note, this.time, this.scheduleHref}) {
    name = JsonInit.stringInit(name);
    id = JsonInit.stringInit(id);
    href = JsonInit.stringInit(href);
    note = JsonInit.stringInit(note);
    stage = JsonInit.stringInit(stage);
    credits = JsonInit.stringInit(credits);
    hours = JsonInit.stringInit(hours);
    scheduleHref = JsonInit.stringInit(scheduleHref);
    time = time ?? {};
  }

  bool get isEmpty {
    return name.isEmpty &&
        href.isEmpty &&
        note.isEmpty &&
        stage.isEmpty &&
        credits.isEmpty &&
        hours.isEmpty &&
        scheduleHref.isEmpty;
  }

  @override
  String toString() {
    return sprintf(
        "name    :%s \nid      :%s \nhref    :%s \nstage   :%s \ncredits :%s \nhours   :%s \nscheduleHref   :%s \nnote    :%s \n",
        [name, id, href, stage, credits, hours, scheduleHref, note]);
  }

  factory CourseMainJson.fromJson(Map<String, dynamic> json) => _$CourseMainJsonFromJson(json);

  Map<String, dynamic> toJson() => _$CourseMainJsonToJson(this);
}

@JsonSerializable()
class CourseExtraJson {
  String id;
  String name;
  String href; //課程名稱用於取得英文
  String category; //類別 (必修...)
  String selectNumber; //選課人數
  String withdrawNumber; //徹選人數
  String openClass; //開課班級(計算學分用)

  CourseExtraJson({this.name, this.category, this.selectNumber, this.withdrawNumber, this.href}) {
    id = JsonInit.stringInit(id);
    name = JsonInit.stringInit(name);
    href = JsonInit.stringInit(href);
    category = JsonInit.stringInit(category);
    selectNumber = JsonInit.stringInit(selectNumber);
    withdrawNumber = JsonInit.stringInit(withdrawNumber);
    openClass = JsonInit.stringInit(openClass);
  }

  bool get isEmpty {
    return id.isEmpty &&
        name.isEmpty &&
        category.isEmpty &&
        selectNumber.isEmpty &&
        withdrawNumber.isEmpty &&
        openClass.isEmpty;
  }

  @override
  String toString() {
    return sprintf(
        "id             :%s \nname           :%s \ncategory       :%s \nselectNumber   :%s \nwithdrawNumber :%s \nopenClass :%s \n",
        [id, name, category, selectNumber, withdrawNumber, openClass]);
  }

  factory CourseExtraJson.fromJson(Map<String, dynamic> json) => _$CourseExtraJsonFromJson(json);

  Map<String, dynamic> toJson() => _$CourseExtraJsonToJson(this);
}

@JsonSerializable()
class ClassJson {
  String name;
  String href;

  ClassJson({this.name, this.href}) {
    name = JsonInit.stringInit(name);
    href = JsonInit.stringInit(href);
  }

  bool get isEmpty {
    return name.isEmpty && href.isEmpty;
  }

  @override
  String toString() {
    return sprintf("name : %s \n" "href : %s \n", [name, href]);
  }

  factory ClassJson.fromJson(Map<String, dynamic> json) => _$ClassJsonFromJson(json);

  Map<String, dynamic> toJson() => _$ClassJsonToJson(this);
}

@JsonSerializable()
class ClassroomJson {
  String name;
  String href;
  bool mainUse;

  ClassroomJson({this.name, this.href, this.mainUse}) {
    name = JsonInit.stringInit(name);
    href = JsonInit.stringInit(href);
    mainUse = mainUse ?? false;
  }

  bool get isEmpty {
    return name.isEmpty && href.isEmpty;
  }

  @override
  String toString() {
    return sprintf("name    : %s \nhref    : %s \nmainUse : %s \n", [name, href, mainUse.toString()]);
  }

  factory ClassroomJson.fromJson(Map<String, dynamic> json) => _$ClassroomJsonFromJson(json);

  Map<String, dynamic> toJson() => _$ClassroomJsonToJson(this);
}

@JsonSerializable()
class TeacherJson {
  String name;
  String href;

  TeacherJson({this.name, this.href}) {
    name = JsonInit.stringInit(name);
    href = JsonInit.stringInit(href);
  }

  bool get isEmpty {
    return name.isEmpty && href.isEmpty;
  }

  @override
  String toString() {
    return sprintf("name : %s \n" "href : %s \n", [name, href]);
  }

  factory TeacherJson.fromJson(Map<String, dynamic> json) => _$TeacherJsonFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherJsonToJson(this);
}

@JsonSerializable()
class SemesterJson {
  String year;
  String semester;

  SemesterJson({this.year, this.semester}) {
    year = JsonInit.stringInit(year);
    semester = JsonInit.stringInit(semester);
  }

  factory SemesterJson.fromJson(Map<String, dynamic> json) => _$SemesterJsonFromJson(json);

  Map<String, dynamic> toJson() => _$SemesterJsonToJson(this);

  bool get isEmpty {
    return year.isEmpty && semester.isEmpty;
  }

  @override
  String toString() {
    return sprintf("year     : %s \n" "semester : %s \n", [year, semester]);
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! SemesterJson) {
      return false;
    }

    final isSemesterSame = int.tryParse(other.semester) == int.tryParse(semester);
    final isYearSame = int.tryParse(other.year) == int.tryParse(year);

    return isSemesterSame && isYearSame;
  }

  @override
  int get hashCode => Object.hashAll([semester.hashCode, year.hashCode]);
}

@JsonSerializable()
class ClassmateJson {
  String departmentName; //電機系
  //String studentEnglishName;
  String studentName;
  String studentId;
  //String href;
  //bool isSelect; //是否撤選

  static const List<Map<String, String>> studentIdData = [
    {
      "code": "01",
      "tw": "教務處",
      "en": "Office of Academic Affairs"
    },
    {
      "code": "05",
      "tw": "進修部",
      "en": "Continuing Education Office"
    },
    {
      "code": "2B",
      "tw": "智動科",
      "en": "Department of Intelligent Automation Engineering"
    },
    {
      "code": "30",
      "tw": "機械系",
      "en": "Department of Mechanical Engineering"
    },
    {
      "code": "40",
      "tw": "機電所",
      "en": "Graduate Institute of Mechatronic Engineering"
    },
    {
      "code": "44",
      "tw": "車輛系",
      "en": "Department of Vehicle Engineering"
    },
    {
      "code": "45",
      "tw": "能源冷凍空調系",
      "en": "Department of Energy and Refrigerating Air-Conditioning Engineering"
    },
    {
      "code": "56",
      "tw": "製科所",
      "en": "Graduate Institute of Manufacturing Technology"
    },
    {
      "code": "61",
      "tw": "自動化所",
      "en": "Graduate Institute of Automation Technology"
    },
    {
      "code": "66",
      "tw": "機電科所",
      "en": "Graduate Institute of Mechanical and Electrical Engineering"
    },
    {
      "code": "81",
      "tw": "機電學士班",
      "en": "Undergraduate Program of Mechanical and Electrical Engineering"
    },
    {
      "code": "A8",
      "tw": "機電科技博士外生專班",
      "en": "International Graduate Institute of Mechanical and Electrical Engineering"
    },
    {
      "code": "AG",
      "tw": "機械自動化外生專班",
      "en": "International Master Program in Mechanical and Automation Engineering"
    },
    {
      "code": "AU",
      "tw": "能源與車輛外生專班",
      "en": "International Master Program in Energy,Refrigerating Air-Conditioning and Vehicle Engineering(IMPEV)"
    },
    {
      "code": "C0",
      "tw": "機電學院",
      "en": "College of Mechanical and Electrical Engineering"
    },
    {
      "code": "32",
      "tw": "化工系",
      "en": "Department of Chemical Engineering and Biotechnology"
    },
    {
      "code": "33",
      "tw": "材資系",
      "en": "Department of Materials and Mineral Resources Engineering"
    },
    {
      "code": "34",
      "tw": "土木系",
      "en": "Department of Civil Engineering"
    },
    {
      "code": "35",
      "tw": "分子系",
      "en": "Department of Molecular Science and Engineering"
    },
    {
      "code": "42",
      "tw": "防災所",
      "en": "Graduate Institute of Civil and Disaster Prevention Engineering"
    },
    {
      "code": "51",
      "tw": "高分所",
      "en": "Graduate Institute of Organic and Polymeric Materials"
    },
    {
      "code": "60",
      "tw": "環境所",
      "en": "Graduate Institute of Environmental Engineering and Management"
    },
    {
      "code": "68",
      "tw": "生化所",
      "en": "Graduate Institute of Biochemical and Biomedical Engineering"
    },
    {
      "code": "73",
      "tw": "化工所",
      "en": "Graduate Institute of Chemical Engineering"
    },
    {
      "code": "78",
      "tw": "材料所",
      "en": "Graduate Institute of Materials Science and Engineering"
    },
    {
      "code": "79",
      "tw": "資源所",
      "en": "Graduate Institute of Mineral Resources Engineering"
    },
    {
      "code": "83",
      "tw": "工程科技學士班",
      "en": "Undergraduate Program of  Engineering technology"
    },
    {
      "code": "A0",
      "tw": "能源光電外國學生專班",
      "en": "International Graduate Program in Energy and Optoelectronic Materials(EOMP)"
    },
    {
      "code": "37",
      "tw": "工管系",
      "en": "Department of Industrial Engineering and Management"
    },
    {
      "code": "57",
      "tw": "經管系",
      "en": "Department of Business Management"
    },
    {
      "code": "74",
      "tw": "管理所",
      "en": "Ph.D. program in Management,College of Management"
    },
    {
      "code": "98",
      "tw": "管理外國學生專班",
      "en": "International Master of Business Administration Program(IMBA)"
    },
    {
      "code": "AB",
      "tw": "資財系",
      "en": "Department of Information and Finance Management"
    },
    {
      "code": "C2",
      "tw": "管理學院",
      "en": "College of Management"
    },
    {
      "code": "38",
      "tw": "工設系",
      "en": "Department of Industrial Design"
    },
    {
      "code": "39",
      "tw": "建築系",
      "en": "Department of Architecture"
    },
    {
      "code": "52",
      "tw": "建都所",
      "en": "Graduate Institute of Architecture and Urban Design"
    },
    {
      "code": "58",
      "tw": "創新所",
      "en": "Graduate Institute of Innovation and Design"
    },
    {
      "code": "84",
      "tw": "創意設計學士班",
      "en": "Undergraduate Program of Creative Design"
    },
    {
      "code": "85",
      "tw": "設計所",
      "en": "Doctoral Program in Design, College of Design"
    },
    {
      "code": "AC",
      "tw": "互動系",
      "en": "Department of Interaction Design"
    },
    {
      "code": "AT",
      "tw": "互動與創新外生專班",
      "en": "International Program for Interaction Design and Innovation"
    },
    {
      "code": "49",
      "tw": "技職所",
      "en": "Graduate Institute of Technological and Vocational Education"
    },
    {
      "code": "54",
      "tw": "英文系",
      "en": "Department of English"
    },
    {
      "code": "91",
      "tw": "科技法律學程",
      "en": "Science and Technology Law Program"
    },
    {
      "code": "A4",
      "tw": "智財所",
      "en": "Graduate Institute of Intellectual Property"
    },
    {
      "code": "A5",
      "tw": "文發系",
      "en": "Department of Cultural Vocation Development"
    },
    {
      "code": "31",
      "tw": "電機系",
      "en": "Department of Electrical Engineering"
    },
    {
      "code": "36",
      "tw": "電子系",
      "en": "Department of Electronic Engineering"
    },
    {
      "code": "59",
      "tw": "資工系",
      "en": "Department of Computer Science and Information Engineering"
    },
    {
      "code": "65",
      "tw": "光電系",
      "en": "Department of Electro-Optical Engineering"
    },
    {
      "code": "82",
      "tw": "電資學士班",
      "en": "Undergraduate Program of Electrical Engineering and Computer Science"
    },
    {
      "code": "99",
      "tw": "電資外國學生專班",
      "en": "International Program of Electrical Engineering and Computer Science(IEECS)"
    },
    {
      "code": "AY",
      "tw": "太空所",
      "en": "Graduate Institute of Aerospace and System Engineering"
    },
    {
      "code": "C5",
      "tw": "電資學院",
      "en": "College of Electric Engineering and Computer Science"
    },
    {
      "code": "C7",
      "tw": "創新學院",
      "en": "Innovation Frontier Institute of Research for Science and Technology"
    }
  ];

  ClassmateJson({/*this.className, this.studentEnglishName,*/ this.studentName, this.studentId/*, this.isSelect, this.href*/}) {
    departmentName = JsonInit.stringInit(departmentName);
    // studentEnglishName = JsonInit.stringInit(studentEnglishName);
    studentName = JsonInit.stringInit(studentName);
    studentId = JsonInit.stringInit(studentId);
    // href = JsonInit.stringInit(href);
    // isSelect = isSelect ?? false;

    for(int i = 0 ; i < studentIdData.length ; i++) {
      if(studentIdData[i]['code'] == studentId.substring(3, 5)) {
        departmentName = studentIdData[i][
          LanguageUtil.getLangIndex() == LangEnum.zh ? 'tw' : 'en'
        ];
        break;
      }

      if(i == studentIdData.length - 1) {
        departmentName = R.current.unknownName;
      }
    }
  }

  bool get isEmpty {
    return studentName.isEmpty && studentId.isEmpty /* && href.isEmpty && className.isEmpty && studentEnglishName.isEmpty */;
  }

  @override
  String toString() {
    return sprintf(
        "departmentName         : %s \nstudentName         : %s \nstudentId           : %s",
        [departmentName, /*studentEnglishName,*/ studentName, studentId, /*href, isSelect.toString()*/]);
  }

  String getName() {
    String name;
    // if (LanguageUtil.getLangIndex() == LangEnum.en) {
    //   name = studentEnglishName;
    // }
    name = name ?? studentName;
    name = (name.contains(RegExp(r"\w"))) ? name : studentName;
    return name;
  }

  factory ClassmateJson.fromJson(Map<String, dynamic> json) => _$ClassmateJsonFromJson(json);

  Map<String, dynamic> toJson() => _$ClassmateJsonToJson(this);
}
