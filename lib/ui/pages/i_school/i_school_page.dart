// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:flutter/material.dart';
import 'package:flutter_app/src/r.dart';

class ISchoolPage extends StatefulWidget {
  const ISchoolPage({Key key}) : super(key: key);

  @override
  State<ISchoolPage> createState() => _ISchoolPageState();
}

class _ISchoolPageState extends State<ISchoolPage> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(R.current.titleNotification),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.info),
            SizedBox(height: 20),
            Text("i 學園介面，即將登場！"),
            SizedBox(height: 20),
            Text("Coming soon!"),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
