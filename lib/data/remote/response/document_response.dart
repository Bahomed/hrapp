// File: lib/data/remote/response/document_response.dart

class DocumentResponse {
  final bool success;
  final String message;
  final List<DocumentResponseData> data;

  DocumentResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DocumentResponse.fromJson(Map<String, dynamic> json) {
    return DocumentResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)
          ?.map((item) => DocumentResponseData.fromJson(item))
          .toList() ?? [],
    );
  }
}

class DocumentSummaryResponse {
  final bool success;
  final String message;
  final DocumentSummaryResponseData data;

  DocumentSummaryResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DocumentSummaryResponse.fromJson(Map<String, dynamic> json) {
    return DocumentSummaryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: DocumentSummaryResponseData.fromJson(json['data'] ?? {}),
    );
  }
}

class DocumentResponseData {
  final int id;
  final String name;
  final String category;
  final String description;
  final String? fileType;
  final String status;
  final String uploadedDate;
  final String? expiryDate;
  final String? downloadUrl;
  final bool isExpiringSoon;
  final int? daysUntilExpiry;
  final String? placeIssued;
  final String? country;
  final String? docNo;

  DocumentResponseData({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.fileType,
    required this.status,
    required this.uploadedDate,
    this.expiryDate,
    this.downloadUrl,
    required this.isExpiringSoon,
    this.daysUntilExpiry,
    this.placeIssued,
    this.country,
    this.docNo,
  });

  factory DocumentResponseData.fromJson(Map<String, dynamic> json) {
    return DocumentResponseData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      fileType: json['file_type'],
      status: json['status'] ?? '',
      uploadedDate: json['uploaded_date'] ?? '',
      expiryDate: json['expiry_date'],
      downloadUrl: json['download_url'],
      isExpiringSoon: json['is_expiring_soon'] ?? false,
      daysUntilExpiry: json['days_until_expiry'],
      placeIssued: json['place_issued'],
      country: json['country'],
      docNo: json['doc_no'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'file_type': fileType,
      'status': status,
      'uploaded_date': uploadedDate,
      'expiry_date': expiryDate,
      'download_url': downloadUrl,
      'is_expiring_soon': isExpiringSoon,
      'days_until_expiry': daysUntilExpiry,
      'place_issued': placeIssued,
      'country': country,
      'doc_no': docNo,
    };
  }

  // Helper methods
  bool get isExpired => status == 'expired';
  bool get isActive => status == 'active';

  String get statusDisplayText {
    switch (status) {
      case 'expired':
        return 'Expired';
      case 'active':
        return 'Active';
      default:
        return 'Unknown';
    }
  }
}

class DocumentSummaryResponseData {
  final int totalDocuments;
  final int activeDocuments;
  final int expiredDocuments;
  final int requiredDocuments;
  final int expiringDocuments;
  final Map<String, int> documentsByCategory;
  final Map<String, int> documentsByStatus;

  DocumentSummaryResponseData({
    required this.totalDocuments,
    required this.activeDocuments,
    required this.expiredDocuments,
    required this.requiredDocuments,
    required this.expiringDocuments,
    required this.documentsByCategory,
    required this.documentsByStatus,
  });

  factory DocumentSummaryResponseData.fromJson(Map<String, dynamic> json) {
    return DocumentSummaryResponseData(
      totalDocuments: json['total_documents'] ?? 0,
      activeDocuments: json['active_documents'] ?? 0,
      expiredDocuments: json['expired_documents'] ?? 0,
      requiredDocuments: json['required_documents'] ?? 0,
      expiringDocuments: json['expiring_documents'] ?? 0,
      documentsByCategory: Map<String, int>.from(json['documents_by_category'] ?? {}),
      documentsByStatus: Map<String, int>.from(json['documents_by_status'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_documents': totalDocuments,
      'active_documents': activeDocuments,
      'expired_documents': expiredDocuments,
      'required_documents': requiredDocuments,
      'expiring_documents': expiringDocuments,
      'documents_by_category': documentsByCategory,
      'documents_by_status': documentsByStatus,
    };
  }
}

class DocumentCategoriesResponse {
  final bool success;
  final String message;
  final List<DocumentCategoryData> data;

  DocumentCategoriesResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DocumentCategoriesResponse.fromJson(Map<String, dynamic> json) {
    return DocumentCategoriesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)
          ?.map((item) => DocumentCategoryData.fromJson(item))
          .toList() ?? [],
    );
  }
}

class DocumentCategoryData {
  final int id;
  final String documentName;
  final bool renewable;
  final bool inHijri;
  final int totalCount;

  DocumentCategoryData({
    required this.id,
    required this.documentName,
    required this.renewable,
    required this.inHijri,
    this.totalCount = 0,
  });

  factory DocumentCategoryData.fromJson(Map<String, dynamic> json) {
    return DocumentCategoryData(
      id: json['id'] ?? 0,
      documentName: json['document_name'] ?? '',
      renewable: _parseBoolFromString(json['renewable']),
      inHijri: _parseBoolFromString(json['in_hijri']),
      totalCount: _parseIntFromJson(json['total_count']),
    );
  }

  static int _parseIntFromJson(dynamic value) {
    if (value == null) {
      return 0;
    }
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed == null) {
        return 0;
      }
      return parsed;
    }
    return 0;
  }

  static bool _parseBoolFromString(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'y' || value.toLowerCase() == 'yes' || value.toLowerCase() == 'true';
    }
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'document_name': documentName,
      'renewable': renewable,
      'in_hijri': inHijri,
      'total_count': totalCount,
    };
  }
}

class DocumentUploadResponse {
  final bool success;
  final String message;

  DocumentUploadResponse({
    required this.success,
    required this.message,
  });

  factory DocumentUploadResponse.fromJson(Map<String, dynamic> json) {
    return DocumentUploadResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '');
  }
}


class DocumentDownloadResponse {
  final bool success;
  final String message;

  DocumentDownloadResponse({
    required this.success,
    required this.message
  });

  factory DocumentDownloadResponse.fromJson(Map<String, dynamic> json) {
    return DocumentDownloadResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? ''
    );
  }
}



// Request Models
class DocumentUploadRequest {
  final int docId;
  final String name;
  final String? notes;
  final String? dateIssuedG;
  final String? dateExpireG;
  final String? docNo;
  final String? category;
  final String? type;
  final String? remarks;
  final bool isDependant;

  DocumentUploadRequest({
    required this.docId,
    required this.name,
    this.notes,
    this.dateIssuedG,
    this.dateExpireG,
    this.docNo,
    this.category,
    this.type,
    this.remarks,
    this.isDependant = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'doc_id': docId,
      'name': name,
      if (notes != null) 'notes': notes,
      if (dateIssuedG != null) 'dateissued_g': dateIssuedG,
      if (dateExpireG != null) 'dateexpire_g': dateExpireG,
      if (docNo != null) 'doc_no': docNo,
      if (category != null) 'category': category,
      if (type != null) 'type': type,
      if (remarks != null) 'remarks': remarks,
      'is_dependant': isDependant,
    };
  }
}

class DocumentUpdateRequest {
  final String? notes;
  final String? dateIssuedG;
  final String? dateExpireG;
  final String? docNo;

  DocumentUpdateRequest({
    this.notes,
    this.dateIssuedG,
    this.dateExpireG,
    this.docNo,
  });

  Map<String, dynamic> toJson() {
    return {
      if (notes != null) 'notes': notes,
      if (dateIssuedG != null) 'dateissued_g': dateIssuedG,
      if (dateExpireG != null) 'dateexpire_g': dateExpireG,
      if (docNo != null) 'doc_no': docNo,
    };
  }
}

