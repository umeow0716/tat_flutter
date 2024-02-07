import 'package:flutter/material.dart';
import 'package:flutter_app/src/r.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(R.current.titleNotification),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mark_chat_unread),
            SizedBox(height: 20),
            Text("訊息功能，即將登場！"),
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
