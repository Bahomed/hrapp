import 'dart:convert';

LoginResponse loginResponseFromJson(String str) => LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
  bool? status;
  int? statusCode;
  bool? error;
  String message;
  int? code;
  Data? data;
  Map<String, dynamic>? errors;
  String? token; // For success response format

  LoginResponse({
    this.status,
    this.statusCode,
    this.error,
    required this.message,
    this.code,
    this.data,
    this.errors,
    this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    status: json["status"],
    statusCode: json["status_code"],
    error: json["error"],
    message: json["message"] ?? "",
    code: json["code"],
    data: json["data"] != null ? Data.fromJson(json["data"]) : null,
    errors: json["errors"],
    token: json["token"], // Direct token field for success response
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "status_code": statusCode,
    "error": error,
    "message": message,
    "code": code,
    "data": data?.toJson(),
    "errors": errors,
    "token": token,
  };

  // Helper methods
  bool get isSuccess => (error == false || status == true) && code == 100;
  bool get isError => error == true || status == false;
  String get accessToken => token ?? data?.token ?? "";
}

class FaceData {
  int? id;
  String? userId;
  String? name;
  String? embeddings;
  String? faceImageBase64;
  String? createdAt;
  String? updatedAt;

  FaceData({
    this.id,
    this.userId,
    this.name,
    this.embeddings,
    this.faceImageBase64,
    this.createdAt,
    this.updatedAt,
  });

  factory FaceData.fromJson(Map<String, dynamic> json) => FaceData(
    id: json["id"],
    userId: json["user_id"] ?? "",
    name: json["name"] ?? "",
    embeddings: json["embeddings"] ?? "",
    faceImageBase64: json["face_image_base64"] ?? "",
    createdAt: json["created_at"] ?? "",
    updatedAt: json["updated_at"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "name": name,
    "embeddings": embeddings,
    "face_image_base64": faceImageBase64,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class Data {
  int? id;
  String? fcmId;
  String? employeeName;
  String? mobileNo;
  String? iqamaNo;
  String? employeeNo;
  String? image;
  String? gender;
  String? email;
  String? preferredLang;
  int? age;
  String? civilStatus;
  String? nationality;
  String? placeOfBirth;
  String? passportNo;
  String? position;
  String? positionIqamaPassport;
  String? department;
  String? section;
  String? localCountry;
<<<<<<< HEAD
  String? localCity;
  String? homeCountry;
  String? homeCity;
  String? currentAddress;
  String? permanentAddress;
  String? token;
  String? reportToEmployee;
=======
  String? homeCountry;
  String? currentAddress;
  String? permanentAddress;
  String? token;
  String? appPassword;
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
  FaceData? faceData;

  Data({
    this.id,
    this.fcmId,
    this.employeeName,
    this.mobileNo,
    this.iqamaNo,
    this.employeeNo,
    this.image,
    this.gender,
    this.email,
    this.preferredLang,
    this.age,
    this.civilStatus,
    this.nationality,
    this.placeOfBirth,
    this.passportNo,
    this.position,
    this.positionIqamaPassport,
    this.department,
    this.section,
    this.localCountry,
<<<<<<< HEAD
    this.localCity,
    this.homeCountry,
    this.homeCity,
    this.currentAddress,
    this.permanentAddress,
    this.token,
    this.reportToEmployee,
=======
    this.homeCountry,
    this.currentAddress,
    this.permanentAddress,
    this.token,
    this.appPassword,
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
    this.faceData,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    fcmId: json["fcm_id"] ?? "",
    employeeName: json["employee_name"] ?? "",
    mobileNo: json["mobile_no"] ?? "",
    iqamaNo: json["iqama_no"] ?? "",
    employeeNo: json["employee_no"] ?? "",
    image: json["image"] ?? "",
    gender: json["gender"] ?? "",
    email: json["email"] ?? "",
    preferredLang: json["preferred_lang"] ?? "",
<<<<<<< HEAD
    age: json["age"] != null ? int.tryParse(json["age"].toString()) : null,
=======
    age: json["age"],
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
    civilStatus: json["civil_status"] ?? "",
    nationality: json["nationality"] ?? "",
    placeOfBirth: json["place_of_birth"] ?? "",
    passportNo: json["passport_no"] ?? "",
    position: json["position"] ?? "",
    positionIqamaPassport: json["position_iqama_passport"] ?? "",
    department: json["department"] ?? "",
    section: json["section"] ?? "",
    localCountry: json["local_country"] ?? "",
<<<<<<< HEAD
    localCity: json["local_city"] ?? "",
    homeCountry: json["home_country"] ?? "",
    homeCity: json["home_city"] ?? "",
    currentAddress: json["current_address"] ?? "",
    permanentAddress: json["permanent_address"] ?? "",
    token: json["token"] ?? "",
    reportToEmployee: json["report_to_employee"] ?? "",
=======
    homeCountry: json["home_country"] ?? "",
    currentAddress: json["current_address"] ?? "",
    permanentAddress: json["permanent_address"] ?? "",
    token: json["token"] ?? "",
    appPassword: json["app_password"] ?? "",
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
    faceData: json["face_data"] != null ? FaceData.fromJson(json["face_data"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "fcm_id": fcmId,
    "employee_name": employeeName,
    "mobile_no": mobileNo,
    "iqama_no": iqamaNo,
    "employee_no": employeeNo,
    "image": image,
    "gender": gender,
    "email": email,
    "preferred_lang": preferredLang,
    "age": age,
    "civil_status": civilStatus,
    "nationality": nationality,
    "place_of_birth": placeOfBirth,
    "passport_no": passportNo,
    "position": position,
    "position_iqama_passport": positionIqamaPassport,
    "department": department,
    "section": section,
    "local_country": localCountry,
<<<<<<< HEAD
    "local_city": localCity,
    "home_country": homeCountry,
    "home_city": homeCity,
    "current_address": currentAddress,
    "permanent_address": permanentAddress,
    "token": token,
    "report_to_employee": reportToEmployee,
=======
    "home_country": homeCountry,
    "current_address": currentAddress,
    "permanent_address": permanentAddress,
    "token": token,
    "app_password": appPassword,
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
    "face_data": faceData?.toJson(),
  };
}