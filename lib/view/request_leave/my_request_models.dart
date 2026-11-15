// Models for the `/api/my/requests...` endpoints (Task 5).
//
// Parsing is defensive (num/string tolerant) because the same endpoints are
// shared with the web and may send numbers as strings.

import 'package:intl/intl.dart';

int? _int(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

double? _double(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

bool _bool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v?.toString().toLowerCase();
  return s == 'true' || s == '1' || s == 'y' || s == 'yes';
}

String? _str(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

/// Formats numbers without a trailing `.0` (1.93 → "1.93", 3.0 → "3").
String formatNumber(num? n) {
  if (n == null) return '';
  if (n == n.roundToDouble()) return n.toInt().toString();
  return n.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
}

// ── Dates: sent / received as YYYY-MM-DD, shown as DD-MM-YYYY ─────────────
final DateFormat _apiDate = DateFormat('yyyy-MM-dd', 'en');
final DateFormat _displayDate = DateFormat('dd-MM-yyyy', 'en');

String toApiDate(DateTime d) => _apiDate.format(d);
String toDisplayDate(DateTime d) => _displayDate.format(d);

/// "2026-11-14" (or an ISO timestamp) → "14-11-2026". Unparseable → as is.
String displayFromApi(String? s) {
  if (s == null || s.isEmpty) return '';
  final d = DateTime.tryParse(s);
  return d == null ? s : toDisplayDate(d);
}

/// "14-11-2026" → DateTime.
DateTime? parseDisplayDate(String s) {
  try {
    return _displayDate.parseStrict(s);
  } catch (_) {
    return null;
  }
}

/// "14-11-2026" → "2026-11-14" (empty when invalid).
String apiFromDisplay(String s) {
  final d = parseDisplayDate(s);
  return d == null ? '' : toApiDate(d);
}

// ── GET my/requests/options ──────────────────────────────────────────────
class MyLeaveType {
  final int id;
  final String name;
  final double? available;
  final double? maxDays;
  final bool phPd;
  final bool allowExceed;
  final bool requiresAttachment;
  final bool requiresTicket;
  final bool requiresExitReentry;

  MyLeaveType({
    required this.id,
    required this.name,
    this.available,
    this.maxDays,
    this.phPd = false,
    this.allowExceed = true,
    this.requiresAttachment = false,
    this.requiresTicket = false,
    this.requiresExitReentry = false,
  });

  factory MyLeaveType.fromJson(Map<String, dynamic> j) => MyLeaveType(
        id: _int(j['id']) ?? 0,
        name: j['name']?.toString() ?? '',
        available: _double(j['available']),
        maxDays: _double(j['max_days']),
        phPd: _bool(j['ph_pd']),
        allowExceed: j['allow_exceed'] == null ? true : _bool(j['allow_exceed']),
        requiresAttachment: _bool(j['requires_attachment']),
        requiresTicket: _bool(j['requires_ticket']),
        requiresExitReentry: _bool(j['requires_exit_reentry']),
      );

  /// The limit the requested days are checked against: `available`, else `max_days`.
  double? get limit => available ?? maxDays;

  /// True when [days] must be blocked: over the limit and the type does not
  /// allow exceeding it (or is a PH/PD type, which never may).
  bool blocks(num days) {
    final l = limit;
    if (l == null) return false;
    return days > l && (!allowExceed || phPd);
  }
}

class MyNamedOption {
  final int id;
  final String name;
  MyNamedOption({required this.id, required this.name});

  factory MyNamedOption.fromJson(Map<String, dynamic> j) =>
      MyNamedOption(id: _int(j['id']) ?? 0, name: j['name']?.toString() ?? '');

  @override
  bool operator ==(Object other) => other is MyNamedOption && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class MyRequestOptions {
  /// Allowed request types: Leave, Permit, Loan, Letter, MissingPunch.
  final List<String> types;
  final bool hasContract;
  final String? hireDate;
  final List<MyLeaveType> leaveTypes;
  final List<MyNamedOption> loanTypes;
  final List<MyNamedOption> letterTypes;

  MyRequestOptions({
    this.types = const [],
    this.hasContract = false,
    this.hireDate,
    this.leaveTypes = const [],
    this.loanTypes = const [],
    this.letterTypes = const [],
  });

  static List<Map<String, dynamic>> _maps(dynamic v) => v is List
      ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
      : const [];

  factory MyRequestOptions.fromJson(Map<String, dynamic> j) => MyRequestOptions(
        types: j['types'] is List
            ? (j['types'] as List).map((e) => e.toString()).toList()
            : const [],
        hasContract: _bool(j['has_contract']),
        hireDate: _str(j['hire_date']),
        leaveTypes: _maps(j['leave_types']).map(MyLeaveType.fromJson).toList(),
        loanTypes: _maps(j['loan_types']).map(MyNamedOption.fromJson).toList(),
        letterTypes: _maps(j['letter_types']).map(MyNamedOption.fromJson).toList(),
      );

  bool allows(String type) => types.contains(type);
}

// ── GET my/requests ──────────────────────────────────────────────────────
class MyRequestItem {
  final int id;
  final String requestNumber;
  final String type; // Leave | Permit | Loan | Letter | MissingPunch | Overtime ...
  final String? subType;
  final String? requestDate;
  final String? startDate;
  final String? endDate;
  final String status;
  final String displayStatus;
  final String? remarks;
  final double? noOfDays;
  final double? amountRequired;
  final bool canDelete;

  MyRequestItem({
    required this.id,
    required this.requestNumber,
    required this.type,
    this.subType,
    this.requestDate,
    this.startDate,
    this.endDate,
    required this.status,
    required this.displayStatus,
    this.remarks,
    this.noOfDays,
    this.amountRequired,
    this.canDelete = false,
  });

  factory MyRequestItem.fromJson(Map<String, dynamic> j) {
    final status = j['status']?.toString() ?? '';
    return MyRequestItem(
      id: _int(j['id']) ?? 0,
      requestNumber: j['request_number']?.toString() ?? '',
      type: j['type']?.toString() ?? '',
      subType: _str(j['sub_type']),
      requestDate: _str(j['request_date']),
      startDate: _str(j['start_date']),
      endDate: _str(j['end_date']),
      status: status,
      displayStatus: _str(j['display_status']) ?? status,
      remarks: _str(j['remarks']),
      noOfDays: _double(j['no_of_days']),
      amountRequired: _double(j['amount_required']),
      canDelete: _bool(j['can_delete']),
    );
  }

  /// Normalised type key: leave, permit, loan, letter, missingpunch, overtime.
  String get typeKey => type.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');

  String get title => subType?.isNotEmpty == true ? subType! : type;
}

/// One approval step of a request (GET my/requests/{id}).
/// The brief only says "who approved, when, comments", so several common
/// key spellings are accepted.
class MyApprovalStep {
  final String? level;
  final String? approver;
  final String? status;
  final String? date;
  final String? comments;

  MyApprovalStep({this.level, this.approver, this.status, this.date, this.comments});

  static String? _first(Map<String, dynamic> j, List<String> keys) {
    for (final k in keys) {
      final v = j[k];
      if (v == null) continue;
      if (v is Map) {
        final n = v['name'] ?? v['employee_name'] ?? v['full_name'];
        if (n != null && n.toString().isNotEmpty) return n.toString();
        continue;
      }
      final s = v.toString();
      if (s.isNotEmpty) return s;
    }
    return null;
  }

  factory MyApprovalStep.fromJson(Map<String, dynamic> j) => MyApprovalStep(
        level: _first(j, ['level', 'level_name', 'step', 'step_no']),
        approver: _first(j, [
          'approver',
          'approver_name',
          'approved_by',
          'action_by',
          'employee',
          'user',
          'name',
        ]),
        status: _first(j, ['status', 'action', 'display_status']),
        date: _first(j, ['action_date', 'acted_at', 'approved_at', 'date', 'updated_at']),
        comments: _first(j, ['comments', 'comment', 'remarks', 'notes']),
      );
}

/// Finds the approval step list in a detail answer, wherever it is nested.
List<MyApprovalStep> parseApprovalSteps(Map<String, dynamic> json) {
  const keys = ['steps', 'approval_steps', 'approvals', 'approval_history'];
  final candidates = <dynamic>[json, json['request'], json['data']];
  for (final c in candidates) {
    if (c is! Map) continue;
    for (final k in keys) {
      final v = c[k];
      if (v is List) {
        return v
            .whereType<Map>()
            .map((e) => MyApprovalStep.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }
  }
  return const [];
}

/// The request object inside a detail answer (`request`, `data`, or the root).
Map<String, dynamic> extractRequestMap(Map<String, dynamic> json) {
  for (final k in ['request', 'data']) {
    final v = json[k];
    if (v is Map && v['id'] != null) return Map<String, dynamic>.from(v);
  }
  return json;
}

// ── GET my/pending ───────────────────────────────────────────────────────
class MyPendingItem {
  final MyRequestItem request;
  final String? level;
  final String? approver;

  MyPendingItem({required this.request, this.level, this.approver});

  factory MyPendingItem.fromJson(Map<String, dynamic> j) {
    String? pick(List<String> keys) {
      for (final k in keys) {
        final v = j[k];
        if (v == null) continue;
        if (v is Map) {
          final n = v['name'] ?? v['employee_name'];
          if (n != null) return n.toString();
          continue;
        }
        if (v is List) {
          final names = v
              .map((e) => e is Map ? (e['name'] ?? e['employee_name']) : e)
              .where((e) => e != null && e.toString().isNotEmpty)
              .join(', ');
          if (names.isNotEmpty) return names;
          continue;
        }
        final s = v.toString();
        if (s.isNotEmpty) return s;
      }
      return null;
    }

    return MyPendingItem(
      request: MyRequestItem.fromJson(j),
      level: pick(['level', 'current_level', 'level_name']),
      approver: pick(['approver', 'approver_name', 'pending_with', 'approvers', 'waiting_for']),
    );
  }
}

/// Reads the list out of a `my/pending` / `my/requests` answer.
List<Map<String, dynamic>> extractList(Map<String, dynamic> json, List<String> keys) {
  for (final k in keys) {
    final v = json[k];
    if (v is List) {
      return v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (v is Map) {
      // e.g. { data: { requests: [...] } }
      final inner = extractList(Map<String, dynamic>.from(v), keys);
      if (inner.isNotEmpty) return inner;
    }
  }
  return const [];
}
