import 'dart:async';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/model/course/course_json.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/task/course/course_extra_info_task.dart';
import 'package:flutter_app/src/task/task_flow.dart';
import 'package:flutter_app/ui/other/route_utils.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:sprintf/sprintf.dart';
import 'package:flutter_app/src/model/course/course_class_json.dart';

class CourseInfoPage extends StatefulWidget {
  final Course course;
  final String studentId;

  const CourseInfoPage(this.studentId, this.course, {super.key});

  final int courseInfoWithAlpha = 0x44;

  @override
  State<CourseInfoPage> createState() => _CourseInfoPageState();
}

class _CourseInfoPageState extends State<CourseInfoPage> with AutomaticKeepAliveClientMixin {
  bool isLoading = true;
  final List<Widget> courseData = [];
  final List<Widget> listItem = [];
  bool canPop = true;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    BackButtonInterceptor.add(myInterceptor);
    Future.delayed(Duration.zero, () {
      _addTask();
    });
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo routeInfo) {
    if (!canPop) {
      Get.back();
    }
    return !canPop;
  }

  void _addTask() async {
    final course = widget.course;
    final taskFlow = TaskFlow();
    final extraTask = CourseExtraInfoTask(course);
    taskFlow.addTask(extraTask);

    await taskFlow.start();

    courseData.add(_buildCourseInfo(sprintf("%s: %s", [R.current.courseId, course.snum])));
    courseData.add(_buildCourseInfo(sprintf("%s: %s", [R.current.courseName, course.name])));
    courseData.add(_buildCourseInfo(sprintf("%s: %s    ", [R.current.credit, course.credits])));
    courseData.add(_buildCourseInfo(sprintf("%s: %s    ", [R.current.category, course.category])));
    courseData.add(
      _buildCourseInfoWithButton(
        sprintf("%s: %s", [R.current.instructor, course.teacher]),
        R.current.syllabus,
        course.snum,
        course.code
      ),
    );

    courseData.add(_buildCourseInfo(sprintf("%s: %s", [R.current.startClass, course.openClass])));
    courseData.add(_buildMultiButtonInfo(
      sprintf("%s: ", [R.current.classroom]),
      R.current.classroomUse,
      course.classroomList,
      course.year,
      course.sem,
      course.classroomCodeList
    ));

    courseData.add(_buildCourseInfo(sprintf("%s: %s", [R.current.numberOfStudent, course.classmateNum])));
    courseData.add(_buildCourseInfo(sprintf("%s: %s", [R.current.numberOfWithdraw,course.leaveNum])));

    listItem.removeRange(0, listItem.length);
    listItem.add(_buildInfoTitle(R.current.courseData));
    listItem.addAll(courseData);

    if(course.classmateList.isNotEmpty) {
      listItem.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
          child: _buildClassmateInfo(1, R.current.kDepartment, R.current.studentId, R.current.name, isHeader: true),
        ),
      );

      for (int i = 0; i < course.classmateList.length; i++) {
        ClassmateJson classmate = course.classmateList[i];
        listItem.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
            child: _buildClassmateInfo(i, classmate.departmentName!, classmate.studentId!, classmate.getName()!),
          ),
        );
      }
    }

    isLoading = false;
    setState(() {});
  }

  Widget _buildClassmateInfo(int index, String departmentName, String studentId, String studentName, { bool isHeader = false }) {
    double height = isHeader ? 25 : 50;

    final color = (index % 2 == 1)
      ? Theme.of(context).colorScheme.surface
      : Theme.of(context).colorScheme.surfaceVariant.withAlpha(widget.courseInfoWithAlpha);
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(width: 4, height: height),
          Expanded(
            child: Text(
              departmentName,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 4, height: height),
          Expanded(
            child: Text(
              studentId,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 4, height: height),
          Expanded(
            child: Text(
              studentName,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); //如果使用AutomaticKeepAliveClientMixin需要呼叫
    return Container(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: <Widget>[
          (isLoading)
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Expanded(
                  child: getAnimationList(),
                ),
        ],
      ),
    );
  }

  Widget getAnimationList() {
    return AnimationLimiter(
      child: ListView.builder(
        itemCount: listItem.length,
        itemBuilder: (BuildContext context, int index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque, //讓透明部分有反應
                  child: Container(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: listItem[index],
                  ),
                  onTap: () {},
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourseInfo(String text) {
    TextStyle textStyle = const TextStyle(fontSize: 18);
    return Container(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: <Widget>[
          const Icon(Icons.details),
          Expanded(
            child: Text(
              text,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }

  void _launchWebView(String title, String urlString) {
    canPop = false;

    final url = Uri.tryParse(urlString);

    if (url != null) {
      RouteUtils.toWebViewPage(initialUrl: url, title: title);
      canPop = true;
    } else {
      // TODO: handle exceptions when the url is null. (null means it may caused by the parse process error.)
    }
  }

  Widget _buildCourseInfoWithButton(String text, String buttonText, String snum, String code) {
    return Container(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          const Icon(Icons.details),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          (snum.isNotEmpty && code.isNotEmpty)
              ? ElevatedButton(
                  child: Text(buttonText),
                  onPressed: () => _launchWebView(buttonText, 'https://aps.ntut.edu.tw/course/tw/ShowSyllabus.jsp?snum=${snum}&code=${code}'),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildInfoTitle(String title) {
    TextStyle textStyle = const TextStyle(fontSize: 24);
    return Container(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        children: <Widget>[
          Text(
            title,
            style: textStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildMultiButtonInfo(String title, String buttonText, List<String> textList, String year, String sem, List<String> idList) {
    const textStyle = TextStyle(fontSize: 18);
    final classroomItemList = <Widget>[];

    for (int i = 0; i < textList.length; i++) {
      final text = textList[i];
      classroomItemList.add(
        FittedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: textStyle,
              ),
              const SizedBox(width: 4),
              idList[i].isNotEmpty
                  ? FittedBox(
                      child: ElevatedButton(
                        onPressed: () => _launchWebView(buttonText, 'https://aps.ntut.edu.tw/course/tw/Croom.jsp?format=-3&year=${year}&sem=${sem}&code=${idList[i]}'),
                        child: Text(buttonText),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.details),
              Text(
                title,
                style: textStyle,
              ),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: classroomItemList,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
