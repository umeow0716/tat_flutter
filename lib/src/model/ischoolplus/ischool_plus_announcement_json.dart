import 'package:json_annotation/json_annotation.dart';

part 'ischool_plus_announcement_json.g.dart';

@JsonSerializable()
class ISchoolPlusAnnouncementInfoJson {
  @JsonKey(name: 'total')
  late int total;

  @JsonKey(name: 'code')
  late int code;

  @JsonKey(name: 'total_rows')
  late String totalRows;

  @JsonKey(name: 'limit_rows')
  late int limitRows;

  @JsonKey(name: 'current_page')
  late String currentPage;

  @JsonKey(name: 'editEnable')
  late String editEnable;

  @JsonKey(name: 'data')
  late String data;

  ISchoolPlusAnnouncementInfoJson(
      this.total, this.code, this.totalRows, this.limitRows, this.currentPage, this.editEnable, this.data);

  factory ISchoolPlusAnnouncementInfoJson.fromJson(Map<String, dynamic> srcJson) =>
      _$ISchoolPlusAnnouncementInfoJsonFromJson(srcJson);
}

@JsonSerializable()
class ISchoolPlusAnnouncementJson {
  late String token;
  late String bid;
  late String nid;

  @JsonKey(name: 'boardid')
  late String boardid;

  @JsonKey(name: 'encbid')
  late String encbid;

  @JsonKey(name: 'node')
  late String node;

  @JsonKey(name: 'encnid')
  late String encnid;

  @JsonKey(name: 'cid')
  late String cid;

  @JsonKey(name: 'enccid')
  late String enccid;

  @JsonKey(name: 'poster')
  late String poster;

  @JsonKey(name: 'realname')
  late String realname;

  @JsonKey(name: 'cpic')
  late String cpic;

  @JsonKey(name: 'subject')
  late String subject;

  @JsonKey(name: 'postdate')
  late String postdate;

  @JsonKey(name: 'postdatelen')
  late String postdatelen;

  @JsonKey(name: 'postcontent')
  late String postcontent;

  @JsonKey(name: 'postcontenttext')
  late String postcontenttext;

  @JsonKey(name: 'hit')
  late String hit;

  @JsonKey(name: 'qrcode_url')
  late String qrcodeUrl;

  @JsonKey(name: 'floor')
  late int floor;

  @JsonKey(name: 'attach')
  late String attach;

  @JsonKey(name: 'postfilelink')
  late String postfilelink;

  @JsonKey(name: 'attachment')
  late String attachment;

  @JsonKey(name: 'n')
  late String n;

  @JsonKey(name: 's')
  late String s;

  @JsonKey(name: 'readflag')
  late int readflag;

  @JsonKey(name: 'postRoles')
  late String postRoles;

  ISchoolPlusAnnouncementJson(
    this.boardid,
    this.encbid,
    this.node,
    this.encnid,
    this.cid,
    this.enccid,
    this.poster,
    this.realname,
    this.cpic,
    this.subject,
    this.postdate,
    this.postdatelen,
    this.postcontent,
    this.postcontenttext,
    this.hit,
    this.qrcodeUrl,
    this.floor,
    this.attach,
    this.postfilelink,
    this.attachment,
    this.n,
    this.s,
    this.readflag,
    this.postRoles,
  );

  factory ISchoolPlusAnnouncementJson.fromJson(Map<String, dynamic> srcJson) =>
      _$ISchoolPlusAnnouncementJsonFromJson(srcJson);
}
