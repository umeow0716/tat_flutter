import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/model/course/course_score_json.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/src/task/course/course_credit_info_task.dart';
import 'package:flutter_app/src/task/course/course_department_task.dart';
import 'package:flutter_app/src/task/course/course_division_task.dart';
import 'package:flutter_app/src/task/course/course_year_task.dart';
import 'package:flutter_app/src/task/task_flow.dart';
import 'package:get/get.dart';

import 'dart:developer' as developer;

class GraduationPicker {
  late GraduationPickerWidget _dialog;
  late BuildContext _dismissingContext;
  bool _barrierDismissible = true;
  bool _isShowing = false;

  GraduationPicker(BuildContext context, {bool? isDismissible}) {
    _barrierDismissible = isDismissible ?? _barrierDismissible; //是否之支援返回關閉
  }

  bool isShowing() {
    return _isShowing;
  }

  void dismiss() {
    if (_isShowing) {
      try {
        _isShowing = false;
        if (Navigator.of(_dismissingContext).canPop()) {
          Navigator.of(_dismissingContext).pop();
        }
      } catch (_) {}
    }
  }

  Future<bool> hide() {
    if (_isShowing) {
      try {
        _isShowing = false;
        Navigator.of(_dismissingContext).pop(true);
        return Future.value(true);
      } catch (_) {
        return Future.value(false);
      }
    } else {
      return Future.value(false);
    }
  }

  Future<bool> show(Function(GraduationInformationJson?) finishCallBack) async {
    if (!_isShowing) {
      try {
        _dialog = const GraduationPickerWidget();
        Get.dialog<GraduationInformationJson>(
          PopScope(
            canPop: false,
            onPopInvoked: (bool _) {
              if(!_barrierDismissible) {
                Navigator.of(_dismissingContext).pop();
              }
            },
            child: Dialog(
              insetAnimationDuration: const Duration(milliseconds: 100),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
              child: _dialog
            )),
          barrierDismissible: false,
        ).then((value) {
          finishCallBack(value);
        });
        // Delaying the function for 200 milliseconds
        // [Default transitionDuration of DialogRoute]
        await Future.delayed(const Duration(milliseconds: 200));
        _isShowing = true;
        return true;
      } catch (_) {
        return false;
      }
    } else {
      return false;
    }
  }
}

class GraduationPickerWidget extends StatefulWidget {
  const GraduationPickerWidget({super.key});

  @override
  State<GraduationPickerWidget> createState() => _GraduationPickerWidget();
}

class _GraduationPickerWidget extends State<GraduationPickerWidget> {
  GraduationInformationJson graduationInformation = GraduationInformationJson();
  List<String> yearList = [];
  List<Map> divisionList = [];
  List<Map> departmentList = [];
  final Map<String, String> _presetDepartment = {};
  String _selectedYear = '';
  Map _selectedDepartment = {};
  Map _selectedDivision = {};
  double width = 60.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      _addSelectTask();
    });
  }

  Future<void> _addSelectTask() async {
    await _getYearList();
    //利用學號預設學年度
    if (graduationInformation.selectYear!.isEmpty) {
      graduationInformation.selectYear = LocalStorage.instance.getAccount()!.substring(0, 3);
    }
    for (String v in yearList) {
      if (v.contains(graduationInformation.selectYear!)) {
        _selectedYear = v;
        break;
      }
    }

    developer.log(graduationInformation.selectDivision.toString());
    if (_presetDepartment.isEmpty) {
      await _getDefaultDepartment();
    } else {
      await selectPreset();
    }

    await _getCreditInfo();
    setState(() {});
  }

  Future<void> _getDefaultDepartment() async {
    bool found = false;
    
    await _getDivisionList(false);
    for(final division in divisionList) {
      await _getDepartmentList(false, division["code"]);
      for(final department in departmentList) {
        if(department["code"]["division"] == LocalStorage.instance.getAccount()!.substring(3, 6)) {
          _selectedDivision = division;
          _selectedDepartment = department;
          found = true;
          break;
        }
      }

      if(found) break;
    }
    
    if(!found) {
      await _getDivisionList();
      await _getDepartmentList();
    }
  }

  Future<void> selectPreset() async {
    //利用北科行動助理預設學制與系所
    if (graduationInformation.selectDivision!.isEmpty) {
      graduationInformation.selectDivision = _presetDepartment["division"]!;
    }
    for (Map v in divisionList) {
      if (graduationInformation.selectDivision == null) {
        break;
      }

      if (v["name"]?.contains(graduationInformation.selectDivision) ?? false) {
        _selectedDivision = v;
        break;
      }
    }
    if (graduationInformation.selectDepartment!.isEmpty) {
      graduationInformation.selectDepartment = _presetDepartment["department"]!;
    }
    for (Map v in departmentList) {
      if (graduationInformation.selectDepartment == null) {
        break;
      }

      if (v["name"]?.contains(graduationInformation.selectDepartment) ?? false) {
        _selectedDepartment = v;
        break;
      }
    }
  }

  Widget buildText(String title) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: Text(title, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  List<DropdownMenuItem> buildYearList() {
    return yearList
        .map(
          (val) => DropdownMenuItem(
            value: val,
            child: buildText(val),
          ),
        )
        .toList();
  }

  List<DropdownMenuItem> buildDivisionList() {
    return divisionList
        .map(
          (val) => DropdownMenuItem(
            value: val,
            child: buildText(val["name"]),
          ),
        )
        .toList();
  }

  List<DropdownMenuItem> buildDepartmentList() {
    return departmentList
        .map(
          (val) => DropdownMenuItem(
            value: val,
            child: buildText(val["name"]),
          ),
        )
        .toList();
  }

  Future<void> _getYearList() async {
    TaskFlow taskFlow = TaskFlow();
    final task = CourseYearTask();
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      yearList = task.result!;
      _selectedYear = yearList.first;
    }
    setState(() {});
  }

  Future<void> _getDivisionList([bool setSelect = true]) async {
    TaskFlow taskFlow = TaskFlow();
    String year = _selectedYear.split(" ")[1];
    var task = CourseDivisionTask(year);
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      divisionList = task.result!;
      if(setSelect) _selectedDivision = divisionList.first;
    }
    setState(() {});
  }

  Future<void> _getDepartmentList([bool setSelect = true, Map<String, String>? code]) async {
    TaskFlow taskFlow = TaskFlow();
    code ??= _selectedDivision["code"];
    final task = CourseDepartmentTask(code!);
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      departmentList = task.result!;
      if(setSelect) _selectedDepartment = departmentList.first;
    }
    setState(() {});
  }

  Future<void> _getCreditInfo() async {
    TaskFlow taskFlow = TaskFlow();
    Map code = _selectedDivision["code"];
    String name = _selectedDepartment["name"];
    var task = CourseCreditInfoTask(code, name);
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      graduationInformation = task.result!;
      graduationInformation.selectYear = _selectedYear;
      graduationInformation.selectDivision = _selectedDivision["name"];
      graduationInformation.selectDepartment = _selectedDepartment["name"];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    width = width * 0.8;

    List<Widget> row1 = [];

    if(buildYearList().isNotEmpty) {
      row1.add(Expanded(
        child: DropdownButton(
          isExpanded: true, //裡面元素是否要Expanded
          value: _selectedYear,
          items: buildYearList(),
          onChanged: (value) {
            setState(() {
              _selectedYear = value;
              _getDivisionList();
            });
          },
        ),
      ));
    }

    if(buildDivisionList().isNotEmpty) {
      try {
        row1.add(Expanded(
          child: DropdownButton(
            isExpanded: true,
            value: _selectedDivision,
            items: buildDivisionList(),
            onChanged: (value) {
              setState(() {
                _selectedDivision = value;
                _getDepartmentList();
              });
            },
          ),
        ));
      } catch(e, stack) {
        Log.eWithStack(e, stack);
      }
    }

    List<Widget> row2 = [];

    if(buildDepartmentList().isNotEmpty) {
      try {
        row2.add(Expanded(
          child: DropdownButton(
            isExpanded: true,
            value: _selectedDepartment,
            items: buildDepartmentList(),
            onChanged: (value) {
              setState(() {
                _selectedDepartment = value;
              });
              _getCreditInfo();
            },
          ),
        ));
      } catch(e, stack) {
        Log.eWithStack(e, stack);
      }
    }
    
    return Container(
      width: width,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  R.current.graduationSetting,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: row1,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: row2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: Text(R.current.cancel),
                    onPressed: () {
                      _cancel();
                    },
                  ),
                  TextButton(
                    child: Text(R.current.save),
                    onPressed: () {
                      _save();
                    },
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  void _save() {
    _returnValue();
  }

  void _cancel() {
    graduationInformation = LocalStorage.instance.getGraduationInformation()!;
    _returnValue();
  }

  void _returnValue() {
    Get.back(result: graduationInformation);
  }
}
