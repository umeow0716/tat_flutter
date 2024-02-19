// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter_app/src/connector/ischool_plus_connector.dart';
import 'package:flutter_app/src/r.dart';

import '../task.dart';
import 'iplus_system_task.dart';

class IPlusCourseClassmateList extends IPlusSystemTask<List<Map<String, String>>> {
  final String id;

  IPlusCourseClassmateList(this.id) : super("IPlusCourseFileTask");

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if (status == TaskStatus.success) {
      super.onStart(R.current.getCourseClassmateList);
      final value = await ISchoolPlusConnector.getCourseClasmateList(id);
      super.onEnd();

      result = value;

      if(result != null) {
        return TaskStatus.success;
      } else {
        return super.onError(R.current.getCourseClassmateListError);
      }
    }
    return status;
  }
}
