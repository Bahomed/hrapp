// To parse this JSON data, do
//
//     final getDashboardResponse = getDashboardResponseFromJson(jsonString);

import 'dart:convert';

GetDashboardResponse getDashboardResponseFromJson(String str) =>
    GetDashboardResponse.fromJson(json.decode(str));

String getDashboardResponseToJson(GetDashboardResponse data) =>
    json.encode(data.toJson());

class GetDashboardResponse {
  int status;
  int statusCode;
  String message;
  Data data;

  GetDashboardResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory GetDashboardResponse.fromJson(Map<String, dynamic> json) =>
      GetDashboardResponse(
        status: json["status"],
        statusCode: json["status_code"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "status_code": statusCode,
        "message": message,
        "data": data.toJson(),
      };
}

class Data {
  String checkPassword;
  String bannerImage;
  String noticeBirthday;
  String bannerurl;
  String appPassword;
  CompanyDetail companyDetail;

  Data(
      {required this.checkPassword,
      required this.bannerImage,
      required this.noticeBirthday,
      required this.bannerurl,
      required this.companyDetail,
      required this.appPassword});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        checkPassword: json["check_password"].toString(),
        bannerImage: json["banner_image"].toString(),
        noticeBirthday: json["notice_birthday"].toString(),
        bannerurl: json["banner_url"].toString(),
        companyDetail: CompanyDetail.fromJson(json["company_detail"]),
        appPassword: json["app_password"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "check_password": checkPassword,
        "banner_image": bannerImage,
        "notice_birthday": noticeBirthday,
        "banner_url": bannerurl,
        "company_detail": companyDetail.toJson(),
      };
}

class CompanyDetail {
  String name;
  String primaryEmail;
  String secondaryEmail;
  String primaryContactNo;
  String secondaryContactNo;
  String address;
  String image;
  String websiteUrl;

  CompanyDetail({
    required this.name,
    required this.primaryEmail,
    required this.secondaryEmail,
    required this.primaryContactNo,
    required this.secondaryContactNo,
    required this.address,
    required this.image,
    required this.websiteUrl,
  });

  factory CompanyDetail.fromJson(Map<String, dynamic> json) => CompanyDetail(
        name: json["name"].toString(),
        primaryEmail: json["primary_email"].toString(),
        secondaryEmail: json["secondary_email"].toString(),
        primaryContactNo: json["primary_contact_no"].toString(),
        secondaryContactNo: json["secondary_contact_no"].toString(),
        address: json["address"].toString(),
        image: json["image"].toString(),
        websiteUrl: json["website_url"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "primary_email": primaryEmail,
        "secondary_email": secondaryEmail,
        "primary_contact_no": primaryContactNo,
        "secondary_contact_no": secondaryContactNo,
        "address": address,
        "image": image,
        "website_url": websiteUrl,
      };
}
