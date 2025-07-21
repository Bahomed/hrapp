

// File: lib/data/remote/response/payslip_download_response.dart
class PayslipDownloadResponse {
  final bool success;
  final PayslipDownload data;
  final String message;

  PayslipDownloadResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory PayslipDownloadResponse.fromJson(Map<String, dynamic> json) {
    return PayslipDownloadResponse(
      success: json['success'] ?? false,
      data: PayslipDownload.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class PayslipDownload {
  final String filename;
  final String pdfBase64;
  final int fileSize;
  final String contentType;

  PayslipDownload({
    required this.filename,
    required this.pdfBase64,
    required this.fileSize,
    required this.contentType,
  });

  factory PayslipDownload.fromJson(Map<String, dynamic> json) {
    return PayslipDownload(
      filename: (json['filename'] ?? 'payslip.pdf').toString(),
      pdfBase64: (json['pdf_base64'] ?? '').toString(),
      fileSize: int.tryParse(json['file_size']?.toString() ?? '0') ?? 0,
      contentType: (json['content_type'] ?? 'application/pdf').toString(),
    );
  }
}
