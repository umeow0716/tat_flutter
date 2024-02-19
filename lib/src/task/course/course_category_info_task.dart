// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter_app/src/connector/course_connector.dart';
import 'package:flutter_app/src/r.dart';

import '../task.dart';
import 'course_system_task.dart';

class CourseCategoryInfoTask extends CourseSystemTask<String> {
  final String id;

  CourseCategoryInfoTask(this.id) : super("CourseCategoryInfoTask");

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();

    if (status == TaskStatus.success) {
      super.onStart(R.current.getCourseDetail);
      final value = await CourseConnector.getCourseCategoryInfo(id);
      super.onEnd();

      if (value != null) {
        result = value;
        return TaskStatus.success;
      } else {
        return await super.onError(R.current.getCourseDetailError);
      }
    }
    return status;
  }
}