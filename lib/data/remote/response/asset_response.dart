import 'dart:convert';

AssetListResponse assetListResponseFromJson(String str) =>
    AssetListResponse.fromJson(json.decode(str));

class AssetListResponse {
  bool error;
  String message;
  int code;
  AssetListData data;

  AssetListResponse({
    required this.error,
    required this.message,
    required this.code,
    required this.data,
  });

  factory AssetListResponse.fromJson(Map<String, dynamic> json) =>
      AssetListResponse(
        error: json["error"] ?? false,
        message: json["message"] ?? '',
        code: json["code"] ?? 200,
        data: AssetListData.fromJson(json["data"] ?? {}),
      );
}

class AssetListData {
  List<AssetAssignmentItem> items;
  AssetPagination pagination;

  AssetListData({required this.items, required this.pagination});

  factory AssetListData.fromJson(Map<String, dynamic> json) {
    final dataJson = json;
    final rawItems = (dataJson["data"] as List<dynamic>?) ?? [];
    final meta = dataJson["meta"] as Map<String, dynamic>?;

    return AssetListData(
      items: rawItems.map((x) => AssetAssignmentItem.fromJson(x)).toList(),
      pagination: AssetPagination.fromMeta(meta ?? {}),
    );
  }
}

class AssetPagination {
  int currentPage;
  int perPage;
  int total;
  int lastPage;
  bool hasMore;

  AssetPagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.hasMore,
  });

  factory AssetPagination.fromMeta(Map<String, dynamic> json) => AssetPagination(
        currentPage: json["current_page"] ?? 1,
        perPage: json["per_page"] ?? 15,
        total: json["total"] ?? 0,
        lastPage: json["last_page"] ?? 1,
        hasMore: (json["current_page"] ?? 1) < (json["last_page"] ?? 1),
      );
}

class AssetAssignmentItem {
  int id;
  String status;
  String? assignedDate;
  String? expectedReturnDate;
  String? returnDate;
  String? conditionAtAssign;
  String? conditionAtReturn;
  String? notes;
  String? assignedBy;
  AssetDetail? asset;

  AssetAssignmentItem({
    required this.id,
    required this.status,
    this.assignedDate,
    this.expectedReturnDate,
    this.returnDate,
    this.conditionAtAssign,
    this.conditionAtReturn,
    this.notes,
    this.assignedBy,
    this.asset,
  });

  factory AssetAssignmentItem.fromJson(Map<String, dynamic> json) =>
      AssetAssignmentItem(
        id: json["id"] ?? 0,
        status: json["status"] ?? '',
        assignedDate: json["assigned_date"],
        expectedReturnDate: json["expected_return_date"],
        returnDate: json["return_date"],
        conditionAtAssign: json["condition_at_assign"],
        conditionAtReturn: json["condition_at_return"],
        notes: json["notes"],
        assignedBy: json["assigned_by"],
        asset: json["asset"] != null ? AssetDetail.fromJson(json["asset"]) : null,
      );
}

class AssetDetail {
  int id;
  String? assetCode;
  String? name;
  String? brand;
  String? model;
  String? serialNumber;
  String? imagePath;
  String? condition;
  String? status;
  String? vendorName;
  String? purchaseDate;
  String? warrantyStart;
  String? warrantyEnd;
  String? notes;
  AssetCategory? category;
  AssetBranch? branch;
  AssetDepartment? department;
  List<dynamic>? maintenances;
  List<dynamic>? documents;

  AssetDetail({
    required this.id,
    this.assetCode,
    this.name,
    this.brand,
    this.model,
    this.serialNumber,
    this.imagePath,
    this.condition,
    this.status,
    this.vendorName,
    this.purchaseDate,
    this.warrantyStart,
    this.warrantyEnd,
    this.notes,
    this.category,
    this.branch,
    this.department,
    this.maintenances,
    this.documents,
  });

  factory AssetDetail.fromJson(Map<String, dynamic> json) => AssetDetail(
        id: json["id"] ?? 0,
        assetCode: json["asset_code"],
        name: json["name"],
        brand: json["brand"],
        model: json["model"],
        serialNumber: json["serial_number"],
        imagePath: json["image_path"],
        condition: json["condition"],
        status: json["status"],
        vendorName: json["vendor_name"],
        purchaseDate: json["purchase_date"],
        warrantyStart: json["warranty_start"],
        warrantyEnd: json["warranty_end"],
        notes: json["notes"],
        category: json["category"] != null
            ? AssetCategory.fromJson(json["category"])
            : null,
        branch: json["branch"] != null
            ? AssetBranch.fromJson(json["branch"])
            : null,
        department: json["department"] != null
            ? AssetDepartment.fromJson(json["department"])
            : null,
        maintenances: json["maintenances"] as List<dynamic>?,
        documents: json["documents"] as List<dynamic>?,
      );
}

class AssetCategory {
  int id;
  String? code;
  String? name;

  AssetCategory({required this.id, this.code, this.name});

  factory AssetCategory.fromJson(Map<String, dynamic> json) => AssetCategory(
        id: json["id"] ?? 0,
        code: json["code"],
        name: json["name"],
      );
}

class AssetBranch {
  int id;
  String? name;

  AssetBranch({required this.id, this.name});

  factory AssetBranch.fromJson(Map<String, dynamic> json) => AssetBranch(
        id: json["id"] ?? 0,
        name: json["name"],
      );
}

class AssetDepartment {
  int id;
  String? name;

  AssetDepartment({required this.id, this.name});

  factory AssetDepartment.fromJson(Map<String, dynamic> json) =>
      AssetDepartment(
        id: json["id"] ?? 0,
        name: json["name"],
      );
}

class AssetSummaryResponse {
  bool error;
  String message;
  int code;
  AssetSummary data;

  AssetSummaryResponse({
    required this.error,
    required this.message,
    required this.code,
    required this.data,
  });

  factory AssetSummaryResponse.fromJson(Map<String, dynamic> json) =>
      AssetSummaryResponse(
        error: json["error"] ?? false,
        message: json["message"] ?? '',
        code: json["code"] ?? 200,
        data: AssetSummary.fromJson(json["data"] ?? {}),
      );
}

class AssetSummary {
  int assigned;
  int returned;
  int overdue;
  int total;

  AssetSummary({
    required this.assigned,
    required this.returned,
    required this.overdue,
    required this.total,
  });

  factory AssetSummary.fromJson(Map<String, dynamic> json) => AssetSummary(
        assigned: json["assigned"] ?? 0,
        returned: json["returned"] ?? 0,
        overdue: json["overdue"] ?? 0,
        total: json["total"] ?? 0,
      );
}

class AssetDetailResponse {
  bool error;
  String message;
  int code;
  AssetAssignmentItem? data;

  AssetDetailResponse({
    required this.error,
    required this.message,
    required this.code,
    this.data,
  });

  factory AssetDetailResponse.fromJson(Map<String, dynamic> json) =>
      AssetDetailResponse(
        error: json["error"] ?? false,
        message: json["message"] ?? '',
        code: json["code"] ?? 200,
        data: json["data"] != null
            ? AssetAssignmentItem.fromJson(json["data"])
            : null,
      );
}
