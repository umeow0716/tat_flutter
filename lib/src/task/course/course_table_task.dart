// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter_app/src/connector/course_connector.dart';
import 'package:flutter_app/src/model/course/course_json.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/src/task/task.dart';
import 'package:flutter_app/src/task/course/course_system_task.dart';

class CourseTableTask extends CourseSystemTask<List<Course>?> {
  final String? year;
  final String? sem;

  CourseTableTask(this.year, this.sem) : super("CourseTableTask");

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if (status == TaskStatus.success) {
      super.onStart(R.current.getCourse);
      result = await CourseConnector.getCourseList(year, sem);
      super.onEnd();
      if (result != null) {
        LocalStorage.instance.addAllCourse(result);
        return TaskStatus.success;
      } else {
        return super.onError(R.current.getCourseError);
      }
    }
    return status;
  }
}
