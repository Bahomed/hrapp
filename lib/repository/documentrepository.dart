import 'dart:io';
import 'package:dio/dio.dart';
import 'package:com.injazatsoftware.injazathr/data/local/preferences.dart';
import 'package:com.injazatsoftware.injazathr/data/remote/dio_client/dio_client.dart';
import 'package:com.injazatsoftware.injazathr/data/remote/network_url/network_url.dart';
import 'package:com.injazatsoftware.injazathr/data/remote/response/document_response.dart';

import '../utils/exceptionhandler.dart';
import '../utils/translation_helper.dart';

class DocumentRepository {
  final Preferences preferences = Preferences();
  final DioClient dioClient = DioClient();

  // Get all documents
  Future<DocumentResponse> getAllDocuments() async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$documentBaseUrl';

      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},

        {'locale': getCurrentLanguage()},
      );
      return DocumentResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is SocketException) {
        throw 'No Internet Connection';
      } else {
        throw exceptionHandler(e);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get specific document by ID
  Future<DocumentResponse> getDocument(String id) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$documentBaseUrl/$id';

      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},

        {'locale': getCurrentLanguage()},
      );
      return DocumentResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is SocketException) {
        throw 'No Internet Connection';
      } else {
        throw exceptionHandler(e);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get document summary/dashboard
  Future<DocumentSummaryResponse> getDocumentSummary() async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$documentBaseUrl/summary/dashboard';

      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},

        {'locale': getCurrentLanguage()},
      );
      return DocumentSummaryResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is SocketException) {
        throw 'No Internet Connection';
      } else {
        throw exceptionHandler(e);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get documents by category
  Future<DocumentResponse> getDocumentsByCategory(String category) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$documentBaseUrl/category/$category';

      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},

        {'locale': getCurrentLanguage()},
      );
      return DocumentResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is SocketException) {
        throw 'No Internet Connection';
      } else {
        throw exceptionHandler(e);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get documents by status
  Future<DocumentResponse> getDocumentsByStatus(String status) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$documentBaseUrl/status/$status';

      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},

        {'locale': getCurrentLanguage()},
      );
      return DocumentResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is SocketException) {
        throw 'No Internet Connection';
      } else {
        throw exceptionHandler(e);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get required documents
  Future<DocumentResponse> getRequiredDocuments() async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$documentBaseUrl/required';

      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},

        {'locale': getCurrentLanguage()},
      );
      return DocumentResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is SocketException) {
        throw 'No Internet Connection';
      } else {
        throw exceptionHandler(e);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get expiring documents
  Future<DocumentResponse> getExpiringDocuments() async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$documentBaseUrl/expiring';

      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},

        {'locale': getCurrentLanguage()},
      );
      return DocumentResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is SocketException) {
        throw 'No Internet Connection';
      } else {
        throw exceptionHandler(e);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get available categories
  Future<DocumentCategoriesResponse> getAvailableCategories() async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$documentBaseUrl/filter/categories';

      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},

        {'locale': getCurrentLanguage()},
      );
      return DocumentCategoriesResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is SocketException) {
        throw 'No Internet Connection';
      } else {
        throw exceptionHandler(e);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Upload document
  Future<DocumentUploadResponse> uploadDocument(DocumentUploadRequest request, File file) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$documentBaseUrl/upload';

      // Create FormData
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
        ...request.toJson(),
      });

      var response = await dioClient.postForImageUpload(
        apiUrl,
        formData,
        {'Authorization': 'Bearer $token'},
      );
      return DocumentUploadResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is SocketException) {
        throw 'No Internet Connection';
      } else {
        throw exceptionHandler(e);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Upload document with FormData (legacy method)
  Future<DocumentUploadResponse> uploadDocumentFormData(FormData formData) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$documentBaseUrl/upload';

      var response = await dioClient.postForImageUpload(
        apiUrl,
        formData,
        {'Authorization': 'Bearer $token'},
      );
      return DocumentUploadResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is SocketException) {
        throw 'No Internet Connection';
      } else {
        throw exceptionHandler(e);
      }
    } catch (e) {
      rethrow;
    }
  }



  // Search documents
  Future<DocumentResponse> searchDocuments(String query) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$documentBaseUrl/search';

      var data = {'query': query};

      var response = await dioClient.post(
        apiUrl,
        data,
        {},
        {'Authorization': 'Bearer $token'},
      );
      return DocumentResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is SocketException) {
        throw 'No Internet Connection';
      } else {
        throw exceptionHandler(e);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Refresh documents
  Future<DocumentResponse> refreshDocuments() async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$documentBaseUrl/refresh';

      var response = await dioClient.post(
        apiUrl,
        {},
        {},
        {'Authorization': 'Bearer $token'},
      );
      return DocumentResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is SocketException) {
        throw 'No Internet Connection';
      } else {
        throw exceptionHandler(e);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Employee-specific methods for viewing subordinate documents

  // Get all documents for specific employee
  Future<DocumentResponse> getAllDocumentsForEmployee(int employeeId) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$documentBaseUrl';

      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {'locale': getCurrentLanguage(), 'emp_id': employeeId},
      );
      return DocumentResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is SocketException) {
        throw 'No Internet Connection';
      } else {
        throw exceptionHandler(e);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get documents by status for specific employee
  Future<DocumentResponse> getDocumentsByStatusForEmployee(String status, int employeeId) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$documentBaseUrl/status/$status';

      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {'locale': getCurrentLanguage(), 'emp_id': employeeId},
      );
      return DocumentResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is SocketException) {
        throw 'No Internet Connection';
      } else {
        throw exceptionHandler(e);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get documents by category for specific employee
  Future<DocumentResponse> getDocumentsByCategoryForEmployee(String category, int employeeId) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$documentBaseUrl/category/$category';

      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {'locale': getCurrentLanguage(), 'emp_id': employeeId},
      );
      return DocumentResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is SocketException) {
        throw 'No Internet Connection';
      } else {
        throw exceptionHandler(e);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get document summary for specific employee
  Future<DocumentSummaryResponse> getDocumentSummaryForEmployee(int employeeId) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$documentBaseUrl/summary/dashboard';

      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {'locale': getCurrentLanguage(), 'emp_id': employeeId},
      );
      return DocumentSummaryResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is SocketException) {
        throw 'No Internet Connection';
      } else {
        throw exceptionHandler(e);
      }
    } catch (e) {
      rethrow;
    }
  }
}