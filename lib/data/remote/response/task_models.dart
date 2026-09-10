// Task Management models — decode the {success, message, data} envelope from
// App\Http\Controllers\Api\TaskController.
//
// Nothing here is a fixed list: task types and statuses are admin-configurable,
// so every board is rendered straight from whatever `columns` the API returns
// and every "move to" action from whatever `statuses` it returns.

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is String) return int.tryParse(v) ?? 0;
  if (v is double) return v.toInt();
  return 0;
}

bool _asBool(dynamic v) {
  if (v is bool) return v;
  if (v is int) return v != 0;
  if (v is String) return v == '1' || v.toLowerCase() == 'true';
  return false;
}

String? _asStringOrNull(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

/// Which board to fetch. The three boards differ only by scope, not shape.
enum TaskBoardType { my, all, team }

/// Generic envelope wrapper. `T` is produced by [parse] from `data`.
class TaskEnvelope<T> {
  final bool success;
  final String message;
  final T? data;

  TaskEnvelope({required this.success, required this.message, this.data});

  factory TaskEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic data) parse,
  ) {
    final raw = json['data'];
    return TaskEnvelope<T>(
      success: _asBool(json['success']),
      message: (json['message'] ?? '').toString(),
      data: raw == null ? null : parse(raw),
    );
  }
}

/// One task card inside a column.
class TaskItem {
  final int id;
  final String taskTypeCode;
  final String taskTypeName;
  final String title;
  final String? description;
  final String? employeeName;
  final String? responsibleNames;
  final String? createdAt;
  final String? completedAt;
  final String? completedByName;
  final String? completionNotes;
  /// Whether the logged-in user is in this task type's responsibility pool
  /// (Settings > Task Responsibility on web). `false` for everyone outside
  /// the pool — admins included, there is no bypass — so the status-change
  /// controls must stay hidden; the server enforces this independently too.
  final bool canChangeStatus;

  TaskItem({
    required this.id,
    required this.taskTypeCode,
    required this.taskTypeName,
    required this.title,
    this.description,
    this.employeeName,
    this.responsibleNames,
    this.createdAt,
    this.completedAt,
    this.completedByName,
    this.completionNotes,
    this.canChangeStatus = false,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: _asInt(json['id']),
      taskTypeCode: (json['task_type_code'] ?? '').toString(),
      taskTypeName: (json['task_type_name'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: _asStringOrNull(json['description']),
      employeeName: _asStringOrNull(json['employee_name']),
      responsibleNames: _asStringOrNull(json['responsible_names']),
      createdAt: _asStringOrNull(json['created_at']),
      completedAt: _asStringOrNull(json['completed_at']),
      completedByName: _asStringOrNull(json['completed_by_name']),
      completionNotes: _asStringOrNull(json['completion_notes']),
      canChangeStatus: _asBool(json['can_change_status']),
    );
  }
}

/// Per-column pagination block. Every column (open and terminal) is paginated
/// the same way; `page` / `per_page` on the board request apply to all columns.
class TaskPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  TaskPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;

  factory TaskPagination.fromJson(Map<String, dynamic> json) {
    return TaskPagination(
      currentPage: _asInt(json['current_page']),
      lastPage: _asInt(json['last_page']),
      perPage: _asInt(json['per_page']),
      total: _asInt(json['total']),
    );
  }
}

/// A status column on a board. `isTerminal` columns are read-only history.
class TaskColumn {
  final String code;
  final String name;
  final String? color; // hex like "#f0ad4e"
  final bool isTerminal;
  final List<TaskItem> tasks;
  final TaskPagination? pagination;

  TaskColumn({
    required this.code,
    required this.name,
    this.color,
    required this.isTerminal,
    required this.tasks,
    this.pagination,
  });

  bool get hasMore => pagination?.hasMore ?? false;

  TaskColumn copyWith({List<TaskItem>? tasks, TaskPagination? pagination}) {
    return TaskColumn(
      code: code,
      name: name,
      color: color,
      isTerminal: isTerminal,
      tasks: tasks ?? this.tasks,
      pagination: pagination ?? this.pagination,
    );
  }

  factory TaskColumn.fromJson(Map<String, dynamic> json) {
    return TaskColumn(
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      color: _asStringOrNull(json['color']),
      isTerminal: _asBool(json['is_terminal']),
      tasks: (json['tasks'] as List? ?? [])
          .map((e) => TaskItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      pagination: json['pagination'] is Map
          ? TaskPagination.fromJson(
              Map<String, dynamic>.from(json['pagination']))
          : null,
    );
  }
}

/// Result of `GET /api/tasks/{my|all|team}-board`.
class TaskBoard {
  final List<TaskColumn> columns;

  TaskBoard({required this.columns});

  int get totalTasks => columns.fold(0, (sum, c) => sum + c.tasks.length);

  factory TaskBoard.fromJson(Map<String, dynamic> json) {
    return TaskBoard(
      columns: (json['columns'] as List? ?? [])
          .map((e) => TaskColumn.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

/// One entry from `GET /api/tasks/statuses` — used to build the "Mark as {name}"
/// buttons on an actionable card.
class TaskStatus {
  final String code;
  final String name;
  final String? color;
  final bool isTerminal;

  TaskStatus({
    required this.code,
    required this.name,
    this.color,
    required this.isTerminal,
  });

  factory TaskStatus.fromJson(Map<String, dynamic> json) {
    return TaskStatus(
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      color: _asStringOrNull(json['color']),
      isTerminal: _asBool(json['is_terminal']),
    );
  }
}

/// One entry from `GET /api/tasks/types` — active task types for the create
/// flow's type picker and the board filter.
class TaskType {
  final String code;
  final String name;

  TaskType({required this.code, required this.name});

  factory TaskType.fromJson(Map<String, dynamic> json) {
    return TaskType(
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }
}

/// One row from `GET /api/tasks/employees/search` — server-side employee picker.
class TaskEmployee {
  final int id;
  final String? email;
  final String? employeeNo;
  final String? nameEn;
  final String? nameAr;

  TaskEmployee({
    required this.id,
    this.email,
    this.employeeNo,
    this.nameEn,
    this.nameAr,
  });

  /// Locale-aware label: falls back to the other language, then employee no.
  String displayName(String locale) {
    final primary = locale == 'ar' ? nameAr : nameEn;
    final name = (primary ?? '').trim().isNotEmpty
        ? primary!.trim()
        : ((nameEn ?? nameAr ?? '').trim());
    if (name.isEmpty) return employeeNo ?? email ?? '#$id';
    return employeeNo != null && employeeNo!.isNotEmpty
        ? '$employeeNo - $name'
        : name;
  }

  factory TaskEmployee.fromJson(Map<String, dynamic> json) {
    return TaskEmployee(
      id: _asInt(json['id']),
      email: _asStringOrNull(json['email']),
      employeeNo: _asStringOrNull(json['employee_no']),
      nameEn: _asStringOrNull(json['name_en']),
      nameAr: _asStringOrNull(json['name_ar']),
    );
  }
}
