import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/remote/response/weekly_shift_schedule_response.dart';
import '../../services/theme_service.dart';
import '../../utils/translation_helper.dart';
import 'manager_weekly_shift_schedule_controller.dart';

// Fixed layout constants
const double _nameColW = 140.0;
const double _dayColW = 96.0;
const double _headerH = 56.0;
const double _rowH = 90.0;

class ManagerWeeklyShiftScheduleScreen extends StatefulWidget {
  const ManagerWeeklyShiftScheduleScreen({super.key});

  @override
  State<ManagerWeeklyShiftScheduleScreen> createState() =>
      _ManagerWeeklyShiftScheduleScreenState();
}

class _ManagerWeeklyShiftScheduleScreenState
    extends State<ManagerWeeklyShiftScheduleScreen> {
  late ManagerWeeklyShiftScheduleController controller;
  final ScrollController _hScroll = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();
  bool _showSearch = false;
  StreamSubscription<bool>? _loadingSub;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ManagerWeeklyShiftScheduleController());
    _loadingSub = controller.isLoading.stream.listen((loading) {
      if (!loading && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToToday());
      }
    });
  }

  @override
  void dispose() {
    _loadingSub?.cancel();
    _hScroll.dispose();
    _searchCtrl.dispose();
    Get.delete<ManagerWeeklyShiftScheduleController>();
    super.dispose();
  }

  void _scrollToToday() {
    if (controller.viewMode.value != 'weekly') return;
    final dates = isRTL()
        ? controller.weekDates.reversed.toList()
        : controller.weekDates;
    final idx = dates.indexWhere((d) => controller.isToday(d));
    if (idx > 0 && _hScroll.hasClients) {
      _hScroll.animateTo(
        idx * _dayColW,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    return Scaffold(
      backgroundColor: theme.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: theme.getCardColor(),
        elevation: 0,
        title: Text(
          tr('weekly_shift_schedule'),
          style: TextStyle(
            color: theme.getTextPrimaryColor(),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: theme.getTextPrimaryColor()),
        actions: [
          IconButton(
            icon: Icon(
              _showSearch ? Icons.search_off : Icons.search,
              color: theme.getTextPrimaryColor(),
            ),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchCtrl.clear();
                  controller.searchQuery.value = '';
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: theme.getTextPrimaryColor()),
            onPressed: controller.fetchData,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          _buildViewTabs(theme),
          _buildNavRow(theme),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _showSearch ? _buildSearchBar(theme) : const SizedBox.shrink(),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: theme.getPrimaryColor()),
                      const SizedBox(height: 16),
                      Text(tr('loading'),
                          style: TextStyle(
                              color: theme.getTextSecondaryColor(),
                              fontSize: 13)),
                    ],
                  ),
                );
              }
              if (controller.errorMessage.value.isNotEmpty) {
                return _buildErrorState(theme);
              }
              if (controller.employees.isEmpty) {
                return _buildEmptyState(theme);
              }
              if (controller.viewMode.value == 'today') {
                return _buildTodayList(theme);
              }
              return _buildGrid(theme);
            }),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // View tabs
  // ──────────────────────────────────────────────

  Widget _buildViewTabs(ThemeService theme) {
    return Obx(() {
      final current = controller.viewMode.value;
      return Container(
        color: theme.getCardColor(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _viewTab('today', tr('day_view'), current, theme),
            const SizedBox(width: 8),
            _viewTab('weekly', tr('week_view'), current, theme),
            const SizedBox(width: 8),
            _viewTab('monthly', tr('month_view'), current, theme),
          ],
        ),
      );
    });
  }

  Widget _viewTab(
      String mode, String label, String current, ThemeService theme) {
    final active = current == mode;
    return GestureDetector(
      onTap: () => controller.setView(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? theme.getPrimaryColor()
              : theme.getPrimaryColor().withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : theme.getPrimaryColor(),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Nav row
  // ──────────────────────────────────────────────

  Widget _buildNavRow(ThemeService theme) {
    return Obx(() {
      final mode = controller.viewMode.value;
      return Container(
        color: theme.getCardColor(),
        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
        child: Row(
          children: [
            if (mode != 'today')
              IconButton(
                icon: Icon(Icons.chevron_left,
                    color: theme.getTextPrimaryColor()),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: mode == 'weekly'
                    ? controller.goToPreviousWeek
                    : controller.goToPreviousMonth,
              ),
            Expanded(
              child: Text(
                controller.periodLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.getTextPrimaryColor(),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (mode != 'today')
              IconButton(
                icon: Icon(Icons.chevron_right,
                    color: theme.getTextPrimaryColor()),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: mode == 'weekly'
                    ? controller.goToNextWeek
                    : controller.goToNextMonth,
              ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: controller.goToToday,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: mode == 'today'
                      ? theme.getPrimaryColor()
                      : Colors.transparent,
                  border: Border.all(color: theme.getPrimaryColor()),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tr('today'),
                  style: TextStyle(
                    color: mode == 'today'
                        ? Colors.white
                        : theme.getPrimaryColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ──────────────────────────────────────────────
  // Search bar
  // ──────────────────────────────────────────────

  Widget _buildSearchBar(ThemeService theme) {
    return Container(
      color: theme.getCardColor(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => controller.searchQuery.value = v,
        decoration: InputDecoration(
          hintText: tr('search'),
          hintStyle: TextStyle(color: theme.getTextSecondaryColor()),
          prefixIcon:
              Icon(Icons.search, color: theme.getTextSecondaryColor(), size: 20),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear,
                      color: theme.getTextSecondaryColor(), size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    controller.searchQuery.value = '';
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: theme.getBackgroundColor(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        style:
            TextStyle(color: theme.getTextPrimaryColor(), fontSize: 13),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Grid (week / month)
  // ──────────────────────────────────────────────

  Widget _buildGrid(ThemeService theme) {
    return Obx(() {
      final employees = controller.filteredEmployees;
      final rawDates = controller.viewMode.value == 'monthly'
          ? controller.monthDates
          : controller.weekDates;

      if (employees.isEmpty) {
        return _buildEmptyState(theme);
      }

      final rtl = isRTL();
      // In RTL: reverse dates so latest day (Sat) is leftmost / immediately visible.
      // In LTR: keep natural Sun→Sat order.
      final dates = rtl ? rawDates.reversed.toList() : rawDates;

      final staffColumn = SizedBox(
        width: _nameColW,
        child: Column(
          children: [
            _buildStaffHeaderCell(theme),
            ...employees.map((emp) => _buildNameCell(emp, theme)),
          ],
        ),
      );

      final dayContent = Directionality(
        textDirection: TextDirection.ltr,
        child: SingleChildScrollView(
          controller: _hScroll,
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: dates.map((d) => _buildDayHeader(d, theme)).toList()),
              ...employees.map((emp) => Row(
                    children: dates.map((d) => _buildCell(emp, d, theme)).toList(),
                  )),
            ],
          ),
        ),
      );

      if (rtl) {
        // RTL: wrap in RTL Directionality → staff column pins to RIGHT, days scroll LEFT
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                staffColumn,
                Expanded(child: dayContent),
              ],
            ),
          ),
        );
      } else {
        // LTR: staff column on LEFT, days scroll to the RIGHT
        return SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              staffColumn,
              Expanded(child: dayContent),
            ],
          ),
        );
      }
    });
  }

  // ── Staff header cell ──

  Widget _buildStaffHeaderCell(ThemeService theme) {
    final rtl = isRTL();
    final separatorSide =
        BorderSide(color: theme.getTextSecondaryColor().withValues(alpha: 0.15));
    return Container(
      height: _headerH,
      width: _nameColW,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.getCardColor(),
        border: Border(
          bottom: BorderSide(
              color: theme.getTextSecondaryColor().withValues(alpha: 0.15)),
          left: rtl ? separatorSide : BorderSide.none,
          right: rtl ? BorderSide.none : separatorSide,
        ),
      ),
      child: Text(
        tr('staff'),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: theme.getTextSecondaryColor(),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ── Day header cell ──

  Widget _buildDayHeader(DateTime date, ThemeService theme) {
    final isToday = controller.isToday(date);
    const abbrevs = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Container(
      width: _dayColW,
      height: _headerH,
      decoration: BoxDecoration(
        color: isToday ? theme.getPrimaryColor() : theme.getCardColor(),
        border: Border(
          bottom: BorderSide(
              color: theme.getTextSecondaryColor().withValues(alpha: 0.15)),
          right: BorderSide(
              color: theme.getTextSecondaryColor().withValues(alpha: 0.08)),
        ),
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: theme.getPrimaryColor().withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            abbrevs[date.weekday % 7],
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isToday
                  ? Colors.white.withValues(alpha: 0.85)
                  : theme.getTextSecondaryColor(),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            date.day.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isToday ? Colors.white : theme.getTextPrimaryColor(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Employee name cell (left column) ──

  Widget _buildNameCell(ManagerShiftEmployee emp, ThemeService theme) {
    final rtl = isRTL();
    final separatorSide =
        BorderSide(color: theme.getTextSecondaryColor().withValues(alpha: 0.15));
    return Container(
      height: _rowH,
      width: _nameColW,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.getCardColor(),
        border: Border(
          bottom: BorderSide(
              color: theme.getTextSecondaryColor().withValues(alpha: 0.10)),
          left: rtl ? separatorSide : BorderSide.none,
          right: rtl ? BorderSide.none : separatorSide,
        ),
      ),
      child: Row(
        children: [
          _buildAvatar(emp, theme),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  emp.name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.getTextPrimaryColor(),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '#${emp.employeeNo}',
                  style: TextStyle(
                    fontSize: 9,
                    color: theme.getTextSecondaryColor(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ManagerShiftEmployee emp, ThemeService theme) {
    final initials = emp.name.trim().isNotEmpty
        ? emp.name.trim().split(' ').take(2).map((w) => w[0]).join()
        : '?';
    if (emp.image != null && emp.image!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          emp.image!,
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsAvatar(initials, theme),
        ),
      );
    }
    return _initialsAvatar(initials, theme);
  }

  Widget _initialsAvatar(String initials, ThemeService theme) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: theme.getPrimaryColor().withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: theme.getPrimaryColor(),
        ),
      ),
    );
  }

  // ── Day cell ──

  Widget _buildCell(
      ManagerShiftEmployee emp, DateTime date, ThemeService theme) {
    final day = controller.getDaySchedule(emp, date);
    final isToday = controller.isToday(date);
    final hasMultiple =
        day != null && day.isWorking && day.sessions.length > 1;

    Widget content;
    if (day != null && day.isWorking && day.sessions.isNotEmpty) {
      content = _buildSessionsContent(day.sessions, isToday, theme);
    } else if (day != null && day.isOff) {
      content = _buildDayOffContent(theme);
    } else {
      content = _buildEmptyContent(theme);
    }

    final cell = Container(
      width: _dayColW,
      height: _rowH,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isToday
            ? theme.getPrimaryColor().withValues(alpha: 0.03)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
              color: theme.getTextSecondaryColor().withValues(alpha: 0.10)),
          right: BorderSide(
              color: theme.getTextSecondaryColor().withValues(alpha: 0.08)),
        ),
      ),
      child: content,
    );

    if (!hasMultiple) return cell;
    return GestureDetector(
      onTap: () => _showSessionsPopup(emp, date, day!.sessions, theme),
      child: cell,
    );
  }

  void _showSessionsPopup(ManagerShiftEmployee emp, DateTime date,
      List<DaySessionEntry> sessions, ThemeService theme) {
    const abbrevs = [
      'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
    ];
    final dayLabel =
        '${abbrevs[date.weekday % 7]} ${date.day}/${date.month}';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: theme.getCardColor(),
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.getTextSecondaryColor().withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              emp.name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: theme.getTextPrimaryColor(),
              ),
            ),
            Text(
              dayLabel,
              style: TextStyle(
                fontSize: 12,
                color: theme.getTextSecondaryColor(),
              ),
            ),
            const SizedBox(height: 16),
            ...sessions.map((e) => _buildPopupSessionRow(e, theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupSessionRow(DaySessionEntry entry, ThemeService theme) {
    final s = entry.session;
    final loc = entry.location;
    final accent = theme.getPrimaryColor();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: theme.getTextSecondaryColor().withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 48,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.timeRange,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
                if (s.name.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(s.name,
                      style: TextStyle(
                          fontSize: 13,
                          color: theme.getTextPrimaryColor())),
                ],
                if (loc != null && loc.name.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(children: [
                    Icon(Icons.location_on_outlined,
                        size: 12,
                        color: theme.getTextSecondaryColor()),
                    const SizedBox(width: 4),
                    Text(loc.name,
                        style: TextStyle(
                            fontSize: 12,
                            color: theme.getTextSecondaryColor())),
                  ]),
                ],
                if (s.gracePeriod != null &&
                    s.gracePeriod!.isNotEmpty &&
                    s.gracePeriod != '0') ...[
                  const SizedBox(height: 3),
                  Row(children: [
                    Icon(Icons.timer_outlined,
                        size: 12,
                        color: theme.getTextSecondaryColor()),
                    const SizedBox(width: 4),
                    Text(
                      '${s.gracePeriod} ${tr('minutes')}',
                      style: TextStyle(
                          fontSize: 12,
                          color: theme.getTextSecondaryColor()),
                    ),
                  ]),
                ],
                if (s.overtime) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF7B68EE).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.more_time,
                            size: 12, color: Color(0xFF7B68EE)),
                        const SizedBox(width: 4),
                        Text(
                          tr('ot'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7B68EE),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsContent(
      List<DaySessionEntry> sessions, bool isToday, ThemeService theme) {
    final accent = theme.getPrimaryColor();
    final first = sessions.first;
    final s = first.session;
    final loc = first.location;
    final extra = sessions.length - 1;

    final rtl = isRTL();
    final accentBar = Container(
      width: 3,
      decoration: BoxDecoration(
        color: accent,
        borderRadius: rtl
            ? const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              )
            : const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        color: isToday
            ? accent.withValues(alpha: 0.08)
            : theme.getCardColor(),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: accent.withValues(alpha: isToday ? 0.5 : 0.2),
          width: isToday ? 1.5 : 1,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            if (!rtl) accentBar,
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      s.timeRange,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                    if (s.name.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        s.name,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: theme.getTextPrimaryColor(),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (loc != null && loc.name.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 8,
                              color: theme.getTextSecondaryColor()),
                          const SizedBox(width: 1),
                          Expanded(
                            child: Text(
                              loc.name,
                              style: TextStyle(
                                  fontSize: 8,
                                  color: theme.getTextSecondaryColor()),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (s.gracePeriod != null &&
                        s.gracePeriod!.isNotEmpty &&
                        s.gracePeriod != '0') ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 8,
                              color: theme.getTextSecondaryColor()),
                          const SizedBox(width: 1),
                          Text(
                            '${s.gracePeriod} ${tr('minutes')}',
                            style: TextStyle(
                                fontSize: 8,
                                color: theme.getTextSecondaryColor()),
                          ),
                        ],
                      ),
                    ],
                    if (s.overtime) ...[
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7B68EE)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.more_time,
                                size: 7, color: Color(0xFF7B68EE)),
                            const SizedBox(width: 1),
                            Text(
                              tr('ot'),
                              style: const TextStyle(
                                fontSize: 7,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF7B68EE),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (extra > 0) ...[
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '+$extra more',
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (rtl) accentBar,
          ],
        ),
      ),
    );
  }

  Widget _buildDayOffContent(ThemeService theme) {
    const amber = Color(0xFFFF9800);
    return Container(
      decoration: BoxDecoration(
        color: amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: amber.withValues(alpha: 0.4)),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.beach_access_outlined, size: 16, color: amber),
          SizedBox(height: 3),
          Text(
            'Day Off',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: amber,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContent(ThemeService theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.getTextSecondaryColor().withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '–',
          style: TextStyle(
            color: theme.getTextSecondaryColor().withValues(alpha: 0.3),
            fontSize: 18,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Today view — list of employees with today's session
  // ──────────────────────────────────────────────

  Widget _buildTodayList(ThemeService theme) {
    return Obx(() {
      final today = DateTime.now();
      final employees = controller.filteredEmployees;
      if (employees.isEmpty) return _buildEmptyState(theme);

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: employees.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final emp = employees[i];
          final day = controller.getDaySchedule(emp, today);
          return _buildTodayEmployeeCard(emp, day, theme);
        },
      );
    });
  }

  Widget _buildTodayEmployeeCard(
      ManagerShiftEmployee emp, DaySchedule? day, ThemeService theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.getCardColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: theme.getTextSecondaryColor().withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Employee header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildAvatar(emp, theme),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        emp.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: theme.getTextPrimaryColor(),
                        ),
                      ),
                      Text(
                        '#${emp.employeeNo}',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.getTextSecondaryColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                if (day != null && day.isWorking && day.sessions.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.getSuccessColor().withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tr('active'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: theme.getSuccessColor(),
                      ),
                    ),
                  )
                else if (day != null && day.isOff)
                  const _OffBadge(),
              ],
            ),
          ),
          // Sessions or day-off or empty
          if (day != null && day.isWorking && day.sessions.isNotEmpty) ...[
            Divider(
                height: 1,
                color: theme.getTextSecondaryColor().withValues(alpha: 0.12)),
            ...day.sessions.map((e) => _buildTodaySessionRow(e, theme)),
          ] else if (day != null && day.isOff)
            _buildTodayOffRow(theme)
          else
            _buildTodayNoSchedule(theme),
        ],
      ),
    );
  }

  Widget _buildTodaySessionRow(DaySessionEntry entry, ThemeService theme) {
    final s = entry.session;
    final loc = entry.location;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.access_time,
              size: 14, color: theme.getPrimaryColor()),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.timeRange,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.getPrimaryColor(),
                  ),
                ),
                if (s.name.isNotEmpty)
                  Text(s.name,
                      style: TextStyle(
                          fontSize: 11,
                          color: theme.getTextPrimaryColor())),
                if (loc != null && loc.name.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 11,
                          color: theme.getTextSecondaryColor()),
                      const SizedBox(width: 3),
                      Text(loc.name,
                          style: TextStyle(
                              fontSize: 11,
                              color: theme.getTextSecondaryColor())),
                    ],
                  ),
                if (s.gracePeriod != null &&
                    s.gracePeriod!.isNotEmpty &&
                    s.gracePeriod != '0')
                  Row(
                    children: [
                      Icon(Icons.timer_outlined,
                          size: 11,
                          color: theme.getTextSecondaryColor()),
                      const SizedBox(width: 3),
                      Text(
                        '${tr('grace_period')}: ${s.gracePeriod} ${tr('minutes')}',
                        style: TextStyle(
                            fontSize: 11,
                            color: theme.getTextSecondaryColor()),
                      ),
                    ],
                  ),
                if (s.overtime)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B68EE).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.more_time,
                            size: 11, color: Color(0xFF7B68EE)),
                        const SizedBox(width: 4),
                        Text(
                          tr('overtime'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7B68EE),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayOffRow(ThemeService theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.beach_access_outlined,
              size: 16, color: Color(0xFFFF9800)),
          const SizedBox(width: 8),
          Text(
            tr('day_off'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF9800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayNoSchedule(ThemeService theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        tr('no_shift_schedule_data'),
        style:
            TextStyle(fontSize: 12, color: theme.getTextSecondaryColor()),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Error / empty states
  // ──────────────────────────────────────────────

  Widget _buildErrorState(ThemeService theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.getErrorColor()),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: theme.getTextSecondaryColor(), fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: controller.fetchData,
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(tr('retry')),
              style: ElevatedButton.styleFrom(
                  backgroundColor: theme.getPrimaryColor(),
                  foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeService theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_view_week_outlined,
              size: 56,
              color: theme.getTextSecondaryColor().withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            tr('no_shift_schedule_data'),
            style: TextStyle(
                color: theme.getTextSecondaryColor(), fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: controller.fetchData,
            icon: Icon(Icons.refresh,
                color: theme.getPrimaryColor(), size: 16),
            label: Text(tr('retry'),
                style: TextStyle(color: theme.getPrimaryColor())),
          ),
        ],
      ),
    );
  }
}

// Small badge widget for "Day Off" status
class _OffBadge extends StatelessWidget {
  const _OffBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Day Off',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFFFF9800),
        ),
      ),
    );
  }
}
