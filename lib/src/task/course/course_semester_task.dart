// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/src/connector/course_connector.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:get/get.dart';
import 'package:numberpicker/numberpicker.dart';

import '../task.dart';
import 'course_system_task.dart';

class CourseSemesterTask extends CourseSystemTask<List<Map<String, String>?>?> {
  final String id;

  CourseSemesterTask(this.id) : super("CourseSemesterTask");

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if (status == TaskStatus.success) {
      List<Map<String, String>?> value = [];

      if (id.length == 5) {
        value = await _selectSemesterDialog();
      } else {
        super.onStart(R.current.getCourseSemester);
        if(id != LocalStorage.instance.getAccount()) {
          final localSemesters = LocalStorage.instance.courses
            .where((course) => course.studentId == id)
            .map((course) => {
              "year": course.year, 
              "sem": course.sem
            })
            .toList();

          for(final semester in localSemesters) {
            final fileted = value.where((target) => 
              target?["year"] == semester["year"] &&
              target?["sem"] == semester["sem"]
            );

            if(fileted.isEmpty) value.add(semester);
          }
        } else {
          value = await CourseConnector.getCourseSemester(id) ?? [];
        }
        super.onEnd();
      }

      if (value != null) {
        result = value;
        return TaskStatus.success;
      } else {
        return super.onError(R.current.getCourseSemesterError);
      }
    }
    return status;
  }

  Future<List<Map<String, String>>> _selectSemesterDialog() async {
    final List<Map<String, String>> value = [];
    final dateTime = DateTime.now();
    int year = dateTime.year - 1911;
    int semester = (dateTime.month <= 8 && dateTime.month >= 1) ? 2 : 1;
    if (dateTime.month <= 1) {
      year--;
    }
    final before = {
      "year": year.toString(),
      "sem": semester.toString()
    };
    final select = await Get.dialog<Map<String, String>>(
          StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: Text(R.current.selectSemester),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: NumberPicker(
                          value: year,
                          minValue: 100,
                          maxValue: 120,
                          onChanged: (value) => setState(() => year = value),
                        ),
                      ),
                      Expanded(
                        child: NumberPicker(
                          value: semester,
                          minValue: 1,
                          maxValue: 2,
                          onChanged: (value) => setState(() => semester = value),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              actions: [
                TextButton(
                  child: Text(R.current.sure),
                  onPressed: () {
                    Get.back<Map<String, String>>(
                      result: {
                        "year": year.toString(),
                        "sem": semester.toString()
                      },
                    );
                  },
                )
              ],
            ),
          ),
        ) ??
        before;
    value.add(select);
    return value;
  }
}
