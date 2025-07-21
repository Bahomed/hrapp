import 'dart:convert';

WorkspaceResponse workspaceResponseFromJson(String str) => WorkspaceResponse.fromJson(json.decode(str));

String workspaceResponseToJson(WorkspaceResponse data) => json.encode(data.toJson());

class WorkspaceResponse {
  bool error;
  String message;
  WorkspaceData? data;  // Made nullable
  int? code;            // Made nullable

  WorkspaceResponse({
    required this.error,
    required this.message,
    this.data,           // Optional
    this.code,           // Optional
  });

  factory WorkspaceResponse.fromJson(Map<String, dynamic> json) => WorkspaceResponse(
    error: json["error"] ?? false,
    message: json["message"] ?? "",
    data: json["data"] != null ? WorkspaceData.fromJson(json["data"]) : null,
    code: json["code"],
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "data": data?.toJson(),
    "code": code,
  };
}

class WorkspaceData {
  int id;
  String name;
  String url;

  WorkspaceData({
    required this.id,
    required this.name,
    required this.url,
  });

  factory WorkspaceData.fromJson(Map<String, dynamic> json) => WorkspaceData(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    url: json["url"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "url": url,
  };
}