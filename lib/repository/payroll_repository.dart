import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injazat_hr_app/data/local/preferences.dart';
import 'package:injazat_hr_app/data/remote/dio_client/dio_client.dart';
import 'package:injazat_hr_app/data/remote/network_url/network_url.dart';
import 'package:injazat_hr_app/data/remote/response/payroll_records_response.dart';
import 'package:injazat_hr_app/data/remote/response/payroll_summary_response.dart';
import 'package:injazat_hr_app/data/remote/response/payroll_years_response.dart';
import 'package:injazat_hr_app/data/remote/response/payslip_download_response.dart';
import '../utils/exceptionhandler.dart';

class PayrollRepository {
final Preferences preferences = Preferences();
final DioClient dioClient = DioClient();

// Get all payroll records
Future<PayrollRecordsResponse> getPayrollRecords() async {
try {
final token = await preferences.getToken();
final workspaceUrl = await preferences.getWorkspaceUrl();
final apiUrl = '$workspaceUrl$payrollBaseUrl';

var response = await dioClient.get(
apiUrl,
{'Authorization': 'Bearer $token'},
{},
);
return PayrollRecordsResponse.fromJson(response.data);
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

// Get specific payroll record by ID
Future<PayrollRecordsResponse> getPayrollRecord(String id) async {
try {
final token = await preferences.getToken();
final workspaceUrl = await preferences.getWorkspaceUrl();
final apiUrl = '$workspaceUrl$payrollBaseUrl/$id';

var response = await dioClient.get(
apiUrl,
{'Authorization': 'Bearer $token'},
{},
);
return PayrollRecordsResponse.fromJson(response.data);
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

// Get payroll summary
Future<PayrollSummaryResponse> getPayrollSummary([String? year]) async {
try {
final token = await preferences.getToken();
final workspaceUrl = await preferences.getWorkspaceUrl();
final yearParam = year ?? '2024';
final apiUrl = '$workspaceUrl$payrollBaseUrl/summary/dashboard/$yearParam';

var response = await dioClient.get(
apiUrl,
{'Authorization': 'Bearer $token'},
{},
);
return PayrollSummaryResponse.fromJson(response.data);
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

// Get payroll records by status
Future<PayrollRecordsResponse> getPayrollRecordsByStatus(String status) async {
try {
final token = await preferences.getToken();
final workspaceUrl = await preferences.getWorkspaceUrl();
final apiUrl = '$workspaceUrl$payrollBaseUrl/status/$status';

var response = await dioClient.get(
apiUrl,
{'Authorization': 'Bearer $token'},
{},
);
return PayrollRecordsResponse.fromJson(response.data);
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

// Get payroll records by year
Future<PayrollRecordsResponse> getPayrollRecordsByYear(String year) async {
try {
final token = await preferences.getToken();
final workspaceUrl = await preferences.getWorkspaceUrl();
final apiUrl = '$workspaceUrl$payrollBaseUrl/year/$year';

var response = await dioClient.get(
apiUrl,
{'Authorization': 'Bearer $token'},
{},
);
return PayrollRecordsResponse.fromJson(response.data);
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

// Get available years
Future<PayrollYearsResponse> getAvailableYears() async {
try {
final token = await preferences.getToken();
final workspaceUrl = await preferences.getWorkspaceUrl();
final apiUrl = '$workspaceUrl$payrollBaseUrl/filter/years';

var response = await dioClient.get(
apiUrl,
{'Authorization': 'Bearer $token'},
{},
);
return PayrollYearsResponse.fromJson(response.data);
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


// Download payslip
Future<PayslipDownloadResponse> downloadPayslip(String payrollId) async {
try {
final token = await preferences.getToken();
final workspaceUrl = await preferences.getWorkspaceUrl();
final apiUrl = '$workspaceUrl$payrollBaseUrl/$payrollId/download';

var response = await dioClient.get(
apiUrl,
{'Authorization': 'Bearer $token'},
{},
);

// Handle case where response might be a direct string or JSON object
if (response.data is String) {
// If response is directly a Base64 string
return PayslipDownloadResponse(
success: true,
data: PayslipDownload(
filename: 'payslip_$payrollId.pdf',
pdfBase64: response.data,
fileSize: 0,
contentType: 'application/pdf',
),
message: 'Payslip downloaded successfully',
);
} else if (response.data is Map<String, dynamic>) {
// If response is a JSON object
return PayslipDownloadResponse.fromJson(response.data);
} else {
throw 'Invalid response format';
}
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


// Refresh payroll data
Future<PayrollRecordsResponse> refreshPayrollData() async {
try {
final token = await preferences.getToken();
final workspaceUrl = await preferences.getWorkspaceUrl();
final apiUrl = '$workspaceUrl$payrollBaseUrl/refresh';

var response = await dioClient.post(
apiUrl,
{},
{},
{'Authorization': 'Bearer $token'},
);
return PayrollRecordsResponse.fromJson(response.data);
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
