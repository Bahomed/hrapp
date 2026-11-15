import 'package:dio/dio.dart';
import 'package:co.injazathr.injazathr/utils/api_result.dart';

/// Message to show for a failed call. Field errors (422) come first,
/// then the server `message`, then a network-level message.
String exceptionHandler(DioException e) {
  final r = ApiResult.fromException(e);
  for (final l in r.fieldErrors.values) {
    if (l.isNotEmpty) return l.first;
  }
  return r.displayMessage();
}
