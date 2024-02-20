// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter_app/src/connector/course_connector.dart';
import 'package:flutter_app/src/model/course/course_json.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/src/task/task.dart';
import 'package:flutter_app/src/task/course/course_system_task.dart';

class CourseTask extends CourseSystemTask<void> {
  final String studentId;
  final Map<String, String> semester;

  CourseTask(this.studentId, this.semester) : super("CourseTask");

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if (status == TaskStatus.success) {
      super.onStart(R.current.getCourse);
      LocalStorage.instance.courses.clear();
      List<Course> result = await CourseConnector.getCourseList(semester["year"], semester["sem"]);
      LocalStorage.instance.courses.addAll(result);
      super.onEnd();
      if(result.isEmpty) return super.onError(R.current.getCourseError);
    }
    return status;
  }
}
