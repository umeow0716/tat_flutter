// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter_app/src/connector/course_connector.dart';
import 'package:flutter_app/src/model/course/course_json.dart';
import 'package:flutter_app/src/r.dart';

import '../task.dart';
import 'course_system_task.dart';

class CourseExtraInfoTask extends CourseSystemTask<bool> {
  final Course course;

  CourseExtraInfoTask(this.course) : super("CourseExtraInfoTask");

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();

    if (status == TaskStatus.success) {
      super.onStart(R.current.getCourseDetail);
      final value = await CourseConnector.getCourseExtraInfo(course);
      super.onEnd();

      if (value) {
        result = value;
        return TaskStatus.success;
      } else {
        return await super.onError(R.current.getCourseDetailError);
      }
    }
    return status;
  }
}
