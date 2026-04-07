import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:co.injazathr.injazathr/data/remote/response/base_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/leave_request_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/permission_request_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/loan_request_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/letter_request_response.dart';
import 'package:co.injazathr.injazathr/repository/requestrepository.dart';
import 'package:co.injazathr.injazathr/services/theme_service.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';

enum RequestDetailType { leave, permit, loan, letter, unknown }

class RequestDetailController extends GetxController {
  final RequestRepository _repository = RequestRepository();

  final int requestId;
  final String? requestType;

  RequestDetailController({required this.requestId, this.requestType});

  final isLoading = true.obs;
  final isDownloading = false.obs;
  final error = Rxn<String>();
  final Rxn<dynamic> detail = Rxn();
  final detectedType = RequestDetailType.unknown.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDetail();
  }

  Future<void> refresh() => _loadDetail();

  Future<void> _loadDetail() async {
    isLoading.value = true;
    error.value = null;
    try {
      final type = _parseType(requestType);
      if (type != RequestDetailType.unknown) {
        await _fetchByType(type);
      } else {
        await _tryAllTypes();
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  RequestDetailType _parseType(String? type) {
    switch (type?.toLowerCase()) {
      case 'leave':
        return RequestDetailType.leave;
      case 'permit':
      case 'permission':
        return RequestDetailType.permit;
      case 'loan':
        return RequestDetailType.loan;
      case 'letter':
        return RequestDetailType.letter;
      default:
        return RequestDetailType.unknown;
    }
  }

  Future<void> _fetchByType(RequestDetailType type) async {
    switch (type) {
      case RequestDetailType.leave:
        final res = await _repository.getLeaveRequestDetails(requestId);
        if (res.success && res.data != null) {
          detail.value = res.data;
          detectedType.value = RequestDetailType.leave;
        } else {
          throw res.message;
        }
        break;
      case RequestDetailType.permit:
        final res = await _repository.getPermissionRequestDetails(requestId);
        if (res.success && res.data != null) {
          detail.value = res.data;
          detectedType.value = RequestDetailType.permit;
        } else {
          throw res.message;
        }
        break;
      case RequestDetailType.loan:
        final res = await _repository.getLoanRequestById(requestId);
        if (res.success && res.data != null) {
          detail.value = res.data;
          detectedType.value = RequestDetailType.loan;
        } else {
          throw res.message.isNotEmpty ? res.message : 'Loan request not found';
        }
        break;
      case RequestDetailType.letter:
        final res = await _repository.getLetterRequestDetails(requestId);
        if (res.success && res.data != null) {
          detail.value = res.data;
          detectedType.value = RequestDetailType.letter;
        } else {
          throw res.message;
        }
        break;
      case RequestDetailType.unknown:
        await _tryAllTypes();
        break;
    }
  }

  Future<void> _tryAllTypes() async {
    try {
      final res = await _repository.getLeaveRequestDetails(requestId);
      if (res.success && res.data != null) {
        detail.value = res.data;
        detectedType.value = RequestDetailType.leave;
        return;
      }
    } catch (_) {}

    try {
      final res = await _repository.getPermissionRequestDetails(requestId);
      if (res.success && res.data != null) {
        detail.value = res.data;
        detectedType.value = RequestDetailType.permit;
        return;
      }
    } catch (_) {}

    try {
      final res = await _repository.getLoanRequestById(requestId);
      if (res.success && res.data != null) {
        detail.value = res.data;
        detectedType.value = RequestDetailType.loan;
        return;
      }
    } catch (_) {}

    try {
      final res = await _repository.getLetterRequestDetails(requestId);
      if (res.success && res.data != null) {
        detail.value = res.data;
        detectedType.value = RequestDetailType.letter;
        return;
      }
    } catch (_) {}

    throw 'Request not found';
  }

  Future<void> downloadLetter() async {
    if (letterDetail == null) return;
    isDownloading.value = true;
    Get.snackbar(
      tr('downloading_letter'),
      '${tr('downloading_letter')}...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: ThemeService.instance.getActionColor('documents'),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
    try {
      final response = await _repository.downloadLetter(letterDetail!.id);
      if (response.success && response.data != null) {
        final downloadUrl = response.data!.downloadUrl;
        final filename = response.data!.filename;
        if (downloadUrl.isEmpty) {
          _showError(tr('failed_to_download_letter'));
          return;
        }
        String fileExtension = filename.contains('.')
            ? filename.substring(filename.lastIndexOf('.'))
            : '.pdf';
        String cleanFilename = filename.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
        if (!cleanFilename.endsWith(fileExtension)) cleanFilename += fileExtension;
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$cleanFilename';
        final dio = Dio();
        await dio.download(downloadUrl, filePath);
        final result = await OpenFile.open(filePath);
        if (result.type == ResultType.done) {
          Get.snackbar(
            tr('success'),
            '${tr('letter_downloaded')}: $cleanFilename',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: ThemeService.instance.getSuccessColor(),
            colorText: Colors.white,
          );
        } else {
          _showError('${tr('failed_to_open_letter')}: ${result.message}');
        }
      } else {
        _showError(tr('failed_to_download_letter'));
      }
    } catch (e) {
      _showError('${tr('error_downloading_letter')}: $e');
    } finally {
      isDownloading.value = false;
    }
  }

  void _showError(String msg) {
    Get.snackbar(
      tr('error'),
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: ThemeService.instance.getErrorColor(),
      colorText: Colors.white,
    );
  }

  // Typed accessors
  LeaveRequest? get leaveDetail =>
      detectedType.value == RequestDetailType.leave ? detail.value as LeaveRequest? : null;

  PermissionRequest? get permitDetail =>
      detectedType.value == RequestDetailType.permit ? detail.value as PermissionRequest? : null;

  LoanRequest? get loanDetail =>
      detectedType.value == RequestDetailType.loan ? detail.value as LoanRequest? : null;

  LetterRequest? get letterDetail =>
      detectedType.value == RequestDetailType.letter ? detail.value as LetterRequest? : null;

  String get requestNumber {
    if (leaveDetail != null) return leaveDetail!.requestNumber;
    if (permitDetail != null) return permitDetail!.requestNumber;
    if (loanDetail != null) return loanDetail!.requestNumber;
    if (letterDetail != null) return letterDetail!.requestNumber;
    return '#$requestId';
  }

  String get status {
    if (leaveDetail != null) return leaveDetail!.status;
    if (permitDetail != null) return permitDetail!.status;
    if (loanDetail != null) return loanDetail!.status;
    if (letterDetail != null) return letterDetail!.status;
    return '';
  }

  String get submittedDate {
    if (leaveDetail != null) return leaveDetail!.submittedDate;
    if (permitDetail != null) return permitDetail!.submittedDate;
    if (loanDetail != null) return loanDetail!.submittedDate;
    if (letterDetail != null) return letterDetail!.submittedDate;
    return '';
  }

  String? get approvedDate {
    if (leaveDetail != null) return leaveDetail!.approvedDate;
    if (permitDetail != null) return permitDetail!.approvedDate;
    if (loanDetail != null) return loanDetail!.approvedDate;
    if (letterDetail != null) return letterDetail!.approvedDate;
    return null;
  }

  String? get rejectedReason {
    if (leaveDetail != null) return leaveDetail!.rejectedReason;
    if (permitDetail != null) return permitDetail!.rejectedReason;
    if (loanDetail != null) return loanDetail!.rejectedReason;
    if (letterDetail != null) return letterDetail!.rejectedReason;
    return null;
  }

  String? get executedDate {
    if (leaveDetail != null) return leaveDetail!.executedDate;
    if (permitDetail != null) return permitDetail!.executedDate;
    if (loanDetail != null) return loanDetail!.executedDate;
    if (letterDetail != null) return letterDetail!.executedDate;
    return null;
  }

  List<Attachment> get attachments {
    if (leaveDetail != null) return leaveDetail!.attachments;
    if (loanDetail != null) return loanDetail!.attachments;
    if (letterDetail != null) return letterDetail!.attachments;
    return [];
  }
}
