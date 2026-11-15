// Models for `GET /api/my/approvals` and its detail / finance endpoints.
//
// The server documents only some shapes (executions, final settlements,
// counts). Everything else is parsed defensively: unknown or missing keys
// fall back to null instead of throwing.

String? _str(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty || s == 'null' ? null : s;
}

int? _int(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? double.tryParse(v.toString())?.toInt();
}

double? _dbl(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString().replaceAll(',', ''));
}

bool _bool(dynamic v) =>
    v == true || v == 1 || v == '1' || v?.toString().toLowerCase() == 'true';

Map<String, dynamic> _map(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

List<Map<String, dynamic>> mapList(dynamic v) {
  if (v is List) {
    return v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }
  // Some endpoints return keyed objects instead of lists.
  if (v is Map) {
    return v.values
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  return [];
}

/// `{ data: {...} }` → inner map; otherwise the map itself.
Map<String, dynamic> unwrapData(Map<String, dynamic> json) {
  final d = json['data'];
  if (d is Map && !json.containsKey('approvals') && !json.containsKey('steps')) {
    return Map<String, dynamic>.from(d);
  }
  return json;
}

class MyEmployee {
  final int? id;
  final String? no;
  final String name;
  final String? avatar;

  const MyEmployee({this.id, this.no, this.name = '', this.avatar});

  factory MyEmployee.fromAny(dynamic v, [Map<String, dynamic>? parent]) {
    if (v is Map) {
      final m = Map<String, dynamic>.from(v);
      return MyEmployee(
        id: _int(m['id']),
        no: _str(m['no'] ?? m['emp_no'] ?? m['employee_no']),
        name: _str(m['name'] ?? m['employee_name'] ?? m['full_name']) ?? '',
        avatar: _str(m['avatar'] ?? m['image'] ?? m['photo']),
      );
    }
    final p = parent ?? const {};
    return MyEmployee(
      id: _int(p['employee_id'] ?? p['emp_id']),
      no: _str(p['employee_no'] ?? p['emp_no']),
      name: _str(v) ?? _str(p['employee_name'] ?? p['name']) ?? '',
      avatar: _str(p['employee_avatar'] ?? p['avatar']),
    );
  }
}

/// One request waiting for my approval step.
class MyApprovalItem {
  final int id;
  final int? stepId;
  final String type;
  final String? subType;
  final String? requestNumber;
  final String? requestDate;
  final String? startDate;
  final String? endDate;
  final String? fromTime;
  final String? toTime;
  final double? noOfDays;
  final double? amount;
  final int? installments;
  final double? hours;
  final String? remarks;
  final String? level;
  final MyEmployee employee;
  final List<String> attachments;
  final Map<String, dynamic> raw;

  MyApprovalItem({
    required this.id,
    this.stepId,
    required this.type,
    this.subType,
    this.requestNumber,
    this.requestDate,
    this.startDate,
    this.endDate,
    this.fromTime,
    this.toTime,
    this.noOfDays,
    this.amount,
    this.installments,
    this.hours,
    this.remarks,
    this.level,
    required this.employee,
    this.attachments = const [],
    this.raw = const {},
  });

  /// Normalised type key: leave, permit, loan, letter, overtime, missingpunch.
  String get typeKey {
    final t = type.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');
    if (t.startsWith('permi')) return 'permit';
    return t;
  }

  factory MyApprovalItem.fromJson(Map<String, dynamic> j) {
    final step = _map(j['step'] ?? j['current_step'] ?? j['my_step']);
    return MyApprovalItem(
      id: _int(j['id'] ?? j['request_id']) ?? 0,
      stepId: _int(j['step_id'] ??
          j['current_step_id'] ??
          j['approval_step_id'] ??
          step['id']),
      type: _str(j['type'] ?? j['request_type']) ?? '',
      subType: _str(j['sub_type'] ??
          j['leave_type'] ??
          j['type_name'] ??
          j['request_type_name']),
      requestNumber: _str(j['request_number'] ?? j['request_no']),
      requestDate: _str(j['request_date'] ?? j['request_date_g'] ?? j['created_at']),
      startDate: _str(j['start_date'] ??
          j['start_date_g'] ??
          j['from_date'] ??
          j['permit_date']),
      endDate: _str(j['end_date'] ?? j['end_date_g'] ?? j['to_date']),
      fromTime: _str(j['permit_from'] ?? j['from_time'] ?? j['time_from']),
      toTime: _str(j['permit_to'] ?? j['to_time'] ?? j['time_to']),
      noOfDays: _dbl(j['no_of_days'] ?? j['days']),
      amount: _dbl(j['amount_required'] ?? j['amount']),
      installments: _int(j['no_of_payments'] ?? j['installments']),
      hours: _dbl(j['total_ot_hours'] ?? j['hours']),
      remarks: _str(j['remarks'] ?? j['reason'] ?? j['notes']),
      level: _str(j['level'] ?? step['level']),
      employee: MyEmployee.fromAny(j['employee'], j),
      attachments: parseAttachments(j),
      raw: j,
    );
  }
}

List<String> parseAttachments(Map<String, dynamic> j) {
  final out = <String>[];
  void add(dynamic v) {
    if (v is String && v.trim().isNotEmpty) {
      out.add(v.trim());
    } else if (v is Map) {
      final u = _str(v['url'] ?? v['file_url'] ?? v['path'] ?? v['file']);
      if (u != null) out.add(u);
    } else if (v is List) {
      for (final e in v) {
        add(e);
      }
    }
  }

  add(j['attachment_url']);
  if (out.isEmpty) add(j['attachment']);
  add(j['attachments']);
  add(j['files']);
  return out.toSet().toList();
}

/// One approval step (who approved, when, comments).
class MyApprovalStep {
  final int? id;
  final String? level;
  final String? approver;
  final String? status;
  final String? actedAt;
  final String? comments;
  final bool canAct;
  final bool isCurrent;

  MyApprovalStep({
    this.id,
    this.level,
    this.approver,
    this.status,
    this.actedAt,
    this.comments,
    this.canAct = false,
    this.isCurrent = false,
  });

  bool get isPending {
    final s = (status ?? '').toLowerCase();
    return s.isEmpty || s == 'pending' || s.contains('approval') || s == 'waiting';
  }

  factory MyApprovalStep.fromJson(Map<String, dynamic> j) {
    final approver = j['approver'];
    return MyApprovalStep(
      id: _int(j['id'] ?? j['step_id']),
      level: _str(j['level'] ?? j['level_name'] ?? j['step']),
      approver: approver is Map
          ? _str(approver['name'] ?? approver['employee_name'])
          : _str(approver ?? j['approver_name'] ?? j['name'] ?? j['role']),
      status: _str(j['status'] ?? j['action']),
      actedAt: _str(j['acted_at'] ??
          j['action_date'] ??
          j['approved_at'] ??
          j['updated_at'] ??
          j['date']),
      comments: _str(j['comments'] ?? j['comment'] ?? j['remarks']),
      // `is_actionable` (server): my pending step at the lowest open level.
      // `is_mine` alone also matches my earlier, already-approved steps.
      canAct: _bool(j['is_actionable'] ?? j['can_act'] ?? j['can_approve']),
      isCurrent: _bool(j['is_current'] ?? j['current']),
    );
  }
}

/// `GET my/approvals/{id}`: the request + its steps + attachment(s).
class MyApprovalDetail {
  final MyApprovalItem request;
  final List<MyApprovalStep> steps;
  final int? myStepId;
  final List<String> attachments;
  final Map<String, dynamic> raw;

  MyApprovalDetail({
    required this.request,
    required this.steps,
    this.myStepId,
    this.attachments = const [],
    this.raw = const {},
  });

  /// Step the signed-in user should act on, best guess first.
  int? get actionableStepId {
    if (myStepId != null) return myStepId;
    if (request.stepId != null) return request.stepId;
    for (final s in steps) {
      if (s.canAct && s.id != null) return s.id;
    }
    for (final s in steps) {
      if (s.isCurrent && s.id != null) return s.id;
    }
    for (final s in steps) {
      if (s.isPending && s.id != null) return s.id;
    }
    return null;
  }

  factory MyApprovalDetail.fromJson(Map<String, dynamic> json, {MyApprovalItem? fallback}) {
    final j = unwrapData(json);
    final reqMap = j['request'] is Map ? _map(j['request']) : j;
    final req = MyApprovalItem.fromJson(reqMap);
    final merged = (req.id == 0 && fallback != null) ? fallback : req;
    final steps = mapList(j['steps'] ?? j['approval_steps'] ?? reqMap['steps'])
        .map(MyApprovalStep.fromJson)
        .toList();
    final atts = {
      ...parseAttachments(j),
      ...parseAttachments(reqMap),
      ...?fallback?.attachments,
    }.toList();
    final my = _map(j['my_step'] ?? j['current_step']);
    return MyApprovalDetail(
      request: merged,
      steps: steps,
      myStepId: _int(j['step_id'] ?? j['my_step_id'] ?? j['current_step_id'] ?? my['id']),
      attachments: atts,
      raw: j,
    );
  }
}

/// Payroll waiting for my approval (approved on the web; read only here).
class MyPayrollItem {
  final Map<String, dynamic> raw;
  MyPayrollItem(this.raw);

  int? get id => _int(raw['id']);

  String get title {
    final name = _str(raw['name'] ?? raw['title'] ?? raw['payroll_name'] ?? raw['branch']);
    final month = _str(raw['month'] ?? raw['month_name']);
    final year = _str(raw['year']);
    final period = _str(raw['period']) ??
        [month, year].whereType<String>().join(' / ');
    return [name, period].where((e) => e != null && e.isNotEmpty).join(' · ');
  }

  double? get total => _dbl(raw['total'] ?? raw['net'] ?? raw['amount'] ?? raw['net_salary']);
  int? get employeesCount => _int(raw['employees'] ?? raw['employees_count'] ?? raw['count']);
  String? get level => _str(raw['level']);
}

class MyLoanInfo {
  final int? requestTypeId;
  final double? amountRequired;
  final int? noOfPayments;
  final String? startDate;

  MyLoanInfo({this.requestTypeId, this.amountRequired, this.noOfPayments, this.startDate});

  factory MyLoanInfo.fromJson(Map<String, dynamic> j) => MyLoanInfo(
        requestTypeId: _int(j['request_type_id']),
        amountRequired: _dbl(j['amount_required']),
        noOfPayments: _int(j['no_of_payments']),
        startDate: _str(j['start_date']),
      );
}

/// `executions[]`: a loan or leave settlement waiting for Finance.
class MyExecutionItem {
  final int id;
  final String type;
  final String? subType;
  final double? amount;
  final String kind; // loan | leave_settlement
  final String? taskDate;
  final MyEmployee employee;
  final MyLoanInfo? loan;
  final Map<String, dynamic> raw;

  MyExecutionItem({
    required this.id,
    required this.type,
    this.subType,
    this.amount,
    required this.kind,
    this.taskDate,
    required this.employee,
    this.loan,
    this.raw = const {},
  });

  bool get isLoan => kind == 'loan';
  bool get isLeaveSettlement => kind == 'leave_settlement';

  factory MyExecutionItem.fromJson(Map<String, dynamic> j) => MyExecutionItem(
        id: _int(j['id']) ?? 0,
        type: _str(j['type']) ?? '',
        subType: _str(j['sub_type']),
        amount: _dbl(j['amount']),
        kind: (_str(j['kind']) ?? '').toLowerCase(),
        taskDate: _str(j['task_date']),
        employee: MyEmployee.fromAny(j['employee'], j),
        loan: j['loan'] is Map ? MyLoanInfo.fromJson(_map(j['loan'])) : null,
        raw: j,
      );
}

/// `final_settlements[]`: task_id, settlement_id, last_day, type, amount, employee.
class MyFinalSettlementItem {
  final int taskId;
  final int? settlementId;
  final String? lastDay;
  final String? type;
  final double? amount;
  final MyEmployee employee;
  final Map<String, dynamic> raw;

  MyFinalSettlementItem({
    required this.taskId,
    this.settlementId,
    this.lastDay,
    this.type,
    this.amount,
    required this.employee,
    this.raw = const {},
  });

  factory MyFinalSettlementItem.fromJson(Map<String, dynamic> j) => MyFinalSettlementItem(
        taskId: _int(j['task_id'] ?? j['id']) ?? 0,
        settlementId: _int(j['settlement_id']),
        lastDay: _str(j['last_day']),
        type: _str(j['type']),
        amount: _dbl(j['amount']),
        employee: MyEmployee.fromAny(j['employee'], j),
        raw: j,
      );
}

/// Whole `GET my/approvals` answer.
class MyApprovalsData {
  final List<MyApprovalItem> approvals;
  final List<MyExecutionItem> executions;
  final List<MyPayrollItem> payrolls;
  final List<MyFinalSettlementItem> finalSettlements;

  MyApprovalsData({
    this.approvals = const [],
    this.executions = const [],
    this.payrolls = const [],
    this.finalSettlements = const [],
  });

  factory MyApprovalsData.fromJson(Map<String, dynamic> json) {
    final j = unwrapData(json);
    return MyApprovalsData(
      approvals: mapList(j['approvals']).map(MyApprovalItem.fromJson).toList(),
      executions: mapList(j['executions']).map(MyExecutionItem.fromJson).toList(),
      payrolls: mapList(j['payrolls']).map(MyPayrollItem.new).toList(),
      finalSettlements:
          mapList(j['final_settlements']).map(MyFinalSettlementItem.fromJson).toList(),
    );
  }
}
