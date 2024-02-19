import 'dart:async';

import 'package:flutter_app/tat_app.dart';
import 'package:flutter_app/debug/log/log.dart';

Future<void> main() async {
  Log.init();

  runZonedGuarded(runTATApp, ((e, stack) => {
    Log.eWithStack(e, stack)
  }));
}
