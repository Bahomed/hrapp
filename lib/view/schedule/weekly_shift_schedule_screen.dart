import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/remote/response/weekly_shift_schedule_response.dart';
import '../../services/theme_service.dart';
import '../../utils/translation_helper.dart';
import 'weekly_shift_schedule_controller.dart';

class WeeklyShiftScheduleScreen extends StatefulWidget {
  const WeeklyShiftScheduleScreen({super.key});

  @override
  State<WeeklyShiftScheduleScreen> createState() =>
      _WeeklyShiftScheduleScreenState();
}

class _WeeklyShiftScheduleScreenState
    extends State<WeeklyShiftScheduleScreen> {
  late WeeklyShiftScheduleController controller;
  final ScrollController _horizontalScroll = ScrollController();
  StreamSubscription<bool>? _loadingSub;

  @override
  void initState() {
    super.initState();
    controller = Get.put(WeeklyShiftScheduleController());
    _loadingSub = controller.isLoading.stream.listen((loading) {
      if (!loading && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToToday());
      }
    });
  }

  @override
  void dispose() {
    _loadingSub?.cancel();
    _horizontalScroll.dispose();
    Get.delete<WeeklyShiftScheduleController>();
    super.dispose();
  }

  void _scrollToToday() {
    final dates = controller.weekDates;
    final idx = dates.indexWhere((d) => controller.isToday(d));
    if (idx > 0 && _horizontalScroll.hasClients) {
      _horizontalScroll.animateTo(
        idx * 124.0,
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
              if (controller.days.isEmpty) {
                return _buildEmptyState(theme);
              }
              return _buildWeekGrid(theme);
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
                icon:
                    Icon(Icons.chevron_left, color: theme.getTextPrimaryColor()),
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
  // Week / month grid
  // ──────────────────────────────────────────────

  Widget _buildWeekGrid(ThemeService theme) {
    return Obx(() {
      final mode = controller.viewMode.value;
      if (mode == 'today') return _buildTodayView(theme);
      final dates =
          mode == 'monthly' ? controller.monthDates : controller.weekDates;
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SingleChildScrollView(
          controller: _horizontalScroll,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                dates.map((date) => _buildDayColumn(date, theme)).toList(),
          ),
        ),
      );
    });
  }

  // ──────────────────────────────────────────────
  // Today full-card view
  // ──────────────────────────────────────────────

  Widget _buildTodayView(ThemeService theme) {
    final today = DateTime.now();
    final day = controller.getDaySchedule(today);
    const abbrevs = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.getPrimaryColor(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.today, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${abbrevs[today.weekday % 7]}, ${today.day} ${_monthName(today.month)} ${today.year}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (day != null && day.isWorking && day.sessions.isNotEmpty)
            ...day.sessions.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildSessionCardFull(e, theme),
                ))
          else if (day != null && day.isOff)
            _buildDayOffCardFull(theme)
          else
            _buildNoScheduleToday(theme),
        ],
      ),
    );
  }

  Widget _buildSessionCardFull(DaySessionEntry entry, ThemeService theme) {
    final s = entry.session;
    final loc = entry.location;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.getCardColor(),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: theme.getPrimaryColor().withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: theme.getPrimaryColor(), size: 18),
              const SizedBox(width: 8),
              Text(
                s.timeRange,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.getPrimaryColor(),
                ),
              ),
            ],
          ),
          if (s.name.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(s.name,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.getTextPrimaryColor())),
          ],
          if (loc != null && loc.name.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 14, color: theme.getTextSecondaryColor()),
                const SizedBox(width: 4),
                Text(loc.name,
                    style: TextStyle(
                        fontSize: 13,
                        color: theme.getTextSecondaryColor())),
              ],
            ),
          ],
          if (s.hrsPerDay != '0') ...[
            const SizedBox(height: 4),
            Text('${s.hrsPerDay} hrs/day',
                style: TextStyle(
                    fontSize: 12, color: theme.getTextSecondaryColor())),
          ],
          if (s.gracePeriod != null && s.gracePeriod!.isNotEmpty && s.gracePeriod != '0') ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.timer_outlined,
                    size: 14, color: theme.getTextSecondaryColor()),
                const SizedBox(width: 4),
                Text(
                  '${tr('grace_period')}: ${s.gracePeriod} ${tr('minutes')}',
                  style: TextStyle(
                      fontSize: 12, color: theme.getTextSecondaryColor()),
                ),
              ],
            ),
          ],
          if (s.overtime) ...[
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF7B68EE).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.more_time,
                      size: 14, color: Color(0xFF7B68EE)),
                  const SizedBox(width: 6),
                  Text(
                    tr('overtime'),
                    style: const TextStyle(
                      fontSize: 12,
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
    );
  }

  Widget _buildDayOffCardFull(ThemeService theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFFFF9800).withValues(alpha: 0.4)),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.beach_access_outlined, size: 40, color: Color(0xFFFF9800)),
            SizedBox(height: 8),
            Text('Day Off',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF9800))),
          ],
        ),
      ),
    );
  }

  Widget _buildNoScheduleToday(ThemeService theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.getTextSecondaryColor().withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(tr('no_shift_schedule_data'),
            style: TextStyle(
                color: theme.getTextSecondaryColor(), fontSize: 14),
            textAlign: TextAlign.center),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Day column (week/month)
  // ──────────────────────────────────────────────

  Widget _buildDayColumn(DateTime date, ThemeService theme) {
    final isToday = controller.isToday(date);
    final day = controller.getDaySchedule(date);
    const abbrevs = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return SizedBox(
      width: 116,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            // Day header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isToday
                    ? theme.getPrimaryColor()
                    : theme.getCardColor(),
                borderRadius: BorderRadius.circular(12),
                boxShadow: isToday
                    ? [
                        BoxShadow(
                          color:
                              theme.getPrimaryColor().withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Column(
                children: [
                  Text(
                    abbrevs[date.weekday % 7],
                    style: TextStyle(
                      fontSize: 11,
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isToday
                          ? Colors.white
                          : theme.getTextPrimaryColor(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // Day content
            if (day != null && day.isWorking && day.sessions.isNotEmpty)
              ...day.sessions
                  .map((e) => _buildSessionCard(e, isToday, theme))
            else if (day != null && day.isOff)
              _buildDayOffCard(theme)
            else
              _buildEmptyDayCard(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(
      DaySessionEntry entry, bool isToday, ThemeService theme) {
    final s = entry.session;
    final loc = entry.location;
    final accent = theme.getPrimaryColor();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isToday
            ? accent.withValues(alpha: 0.08)
            : theme.getCardColor(),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: accent.withValues(alpha: isToday ? 0.5 : 0.2),
          width: isToday ? 1.5 : 1,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 3,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.timeRange,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                    if (s.name.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        s.name,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: theme.getTextPrimaryColor(),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (loc != null && loc.name.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 9,
                              color: theme.getTextSecondaryColor()),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              loc.name,
                              style: TextStyle(
                                  fontSize: 9,
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
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 9,
                              color: theme.getTextSecondaryColor()),
                          const SizedBox(width: 2),
                          Text(
                            '${s.gracePeriod} ${tr('minutes')}',
                            style: TextStyle(
                                fontSize: 9,
                                color: theme.getTextSecondaryColor()),
                          ),
                        ],
                      ),
                    ],
                    if (s.overtime) ...[
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7B68EE).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.more_time,
                                size: 8, color: Color(0xFF7B68EE)),
                            const SizedBox(width: 2),
                            Text(
                              tr('ot'),
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF7B68EE),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.getSuccessColor().withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tr('active'),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: theme.getSuccessColor(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayOffCard(ThemeService theme) {
    const amber = Color(0xFFFF9800);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: amber.withValues(alpha: 0.45)),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.beach_access_outlined, size: 20, color: amber),
          SizedBox(height: 5),
          Text(
            'Day Off',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: amber,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDayCard(ThemeService theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.getTextSecondaryColor().withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: theme.getTextSecondaryColor().withValues(alpha: 0.1)),
      ),
      child: Center(
        child: Text(
          '–',
          style: TextStyle(
            color: theme.getTextSecondaryColor().withValues(alpha: 0.35),
            fontSize: 22,
            fontWeight: FontWeight.w300,
          ),
        ),
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
              style:
                  TextStyle(color: theme.getTextSecondaryColor(), fontSize: 13),
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
            style:
                TextStyle(color: theme.getTextSecondaryColor(), fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: controller.fetchData,
            icon: Icon(Icons.refresh, color: theme.getPrimaryColor(), size: 16),
            label: Text(tr('retry'),
                style: TextStyle(color: theme.getPrimaryColor())),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────

  String _monthName(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m];
  }
}
