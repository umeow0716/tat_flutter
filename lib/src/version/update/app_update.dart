// ignore_for_file: import_of_legacy_library_into_null_safe
import 'dart:convert';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/connector/core/connector.dart';
import 'package:flutter_app/src/connector/core/connector_parameter.dart';
import 'package:flutter_app/src/model/remoteconfig/remote_config_version_info.dart';
import 'package:flutter_app/src/r.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:sprintf/sprintf.dart';
import 'package:version/version.dart';
import 'package:flutter_install_app/flutter_install_app.dart';

import 'dart:developer' as developer;

class AppUpdate {
  static const String _versionsURL = "https://tat.umeow.eu.org/versions.json";

  static Future<bool> checkUpdate({RemoteConfigVersionInfo? versionConfig}) async {
    try {
      final latestVersionData = await getLatestVersionData();
      final latestVersion = Version.parse(latestVersionData['latest']);

      final currentVersion = Version.parse( await getAppVersion() );

      if(latestVersion > currentVersion) {
        _showUpdateDialog(latestVersionData);
        return true;
      }
    } catch(_) {
      return false;
    }
    return false;
  }

  static Future<String> getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static Future<dynamic> getLatestVersionData() async {
    final parameter = ConnectorParameter(_versionsURL);
    final response = await Connector.getDataByGet(parameter);
    final result = jsonDecode(response.toString());

    return result;
  }

  static Future<String> getLatestVersionString() async {
    dynamic data = await getLatestVersionData();
    return data['latest'];
  }

  static void _showUpdateDialog(dynamic latestVersionData) async {
    final latest = latestVersionData['latest'];
    final title = sprintf("%s %s", [R.current.findNewVersion, latest]);

    await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text(latestVersionData['detail']),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text(R.current.cancel),
            onPressed: () => Get.back<bool>(result: false),
          ),
          DynamicButton(latest),
        ],
      ),
      barrierDismissible: false, // user must tap button!
    );
    // if (value.isFocusUpdate) {
    //   MyToast.show(R.current.appWillClose);
    //   await Future.delayed(const Duration(seconds: 1));
    //   SystemNavigator.pop();
    //   exit(0);
    // }
  }
}

class DynamicButton extends StatefulWidget {
  final String latest;

  const DynamicButton(this.latest, {super.key});

  @override
  _DynamicButton createState() => _DynamicButton();
}

class _DynamicButton extends State<StatefulWidget> {
  String _data = '更新';
  bool _isPressed = false;

  buttonOnPress() async {
    if(_isPressed) return;
    _isPressed = true;
    developer.log('更新APP...');
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      String targetABI = androidInfo.supportedAbis[0];
      String latest = await AppUpdate.getLatestVersionString();
      String filename;

      if(targetABI == 'x86_64') {
        filename = 'TAT_umeow_V${latest}_x86_64.apk';
      } else if(targetABI == 'arm64-v8a') {
        filename = 'TAT_umeow_V${latest}_v8a.apk';
      } else if(targetABI == 'armeabi-v7a') {
        filename = 'TAT_umeow_V${latest}_v7a.apk';
      } else {
        filename = 'TAT_umeow_V$latest.apk';
      }

      final dio = Dio();

      final response = await dio.get(
        'https://tat.umeow.eu.org/$latest/$filename', 
        onReceiveProgress: (int count, int total) {
          setState(() {
            _data = '${count ~/ 1024}/${total ~/ 1024} KB';
          });
        },
        options: Options(responseType: ResponseType.bytes),
      );
      setState(() {
        _data = R.current.downloadComplete;
      });
      AppInstaller.installApkBytes( Uint8List.fromList(response.data) );
    } catch(_) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: buttonOnPress,
      child: Text(_data),
    );
  }
}
