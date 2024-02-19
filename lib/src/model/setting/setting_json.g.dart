// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting_json.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingJson _$SettingJsonFromJson(Map<String, dynamic> json) => SettingJson(
      other: json['other'] == null
          ? null
          : OtherSettingJson.fromJson(json['other'] as Map<String, dynamic>),
      announcement: json['announcement'] == null
          ? null
          : AnnouncementSettingJson.fromJson(
              json['announcement'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SettingJsonToJson(SettingJson instance) =>
    <String, dynamic>{
      'other': instance.other,
      'announcement': instance.announcement,
    };

AnnouncementSettingJson _$AnnouncementSettingJsonFromJson(
        Map<String, dynamic> json) =>
    AnnouncementSettingJson(
      page: json['page'] as int?,
      maxPage: json['maxPage'] as int?,
    );

Map<String, dynamic> _$AnnouncementSettingJsonToJson(
        AnnouncementSettingJson instance) =>
    <String, dynamic>{
      'page': instance.page,
      'maxPage': instance.maxPage,
    };

OtherSettingJson _$OtherSettingJsonFromJson(Map<String, dynamic> json) =>
    OtherSettingJson(
      lang: json['lang'] as String?,
      autoCheckAppUpdate: json['autoCheckAppUpdate'] as bool?,
      useExternalVideoPlayer: json['useExternalVideoPlayer'] as bool?,
      checkIPlusNew: json['checkIPlusNew'] as bool?,
    );

Map<String, dynamic> _$OtherSettingJsonToJson(OtherSettingJson instance) =>
    <String, dynamic>{
      'lang': instance.lang,
      'autoCheckAppUpdate': instance.autoCheckAppUpdate,
      'useExternalVideoPlayer': instance.useExternalVideoPlayer,
      'checkIPlusNew': instance.checkIPlusNew,
    };
