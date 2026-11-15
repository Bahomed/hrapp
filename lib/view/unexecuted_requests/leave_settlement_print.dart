import 'package:printing/printing.dart';

/// Printed "Employee Leave Settlement" — a port of the web's
/// resources/js/views/TenantApp/leaves/printSettlement.js (Injazathr's
/// leave-settlement-print, document control HR018): company - branch, title,
/// the boxed info table, Due To Employee (benefits + total due), Deductions
/// (+ total owed), Final Amount, approval signatures, clearance text,
/// Received / Signature and the footer. Labels: the web's
/// leaveSettlement.print.* (en / ar).
///
/// [s] = the `settlement` object of GET my/executions/{id}/settlement.
class LeaveSettlementPrint {
  static const _en = {
    'title': 'Employee Leave Settlement', 'date': 'Date', 'empNo': 'Employee No', 'iqama': 'ID/IQAMA #',
    'empName': 'Employee Name', 'department': 'Department', 'section': 'Section', 'position': 'Position',
    'nationality': 'Nationality', 'leaveType': 'Leave Type', 'workFrom': 'Work From', 'workTo': 'Work To Date',
    'employmentStart': 'Employment Start Date', 'basicSalary': 'Basic Salary', 'vacationStart': 'Vacation Start Date',
    'vacationEnd': 'Vacation End Date', 'periodWorked': 'Period Worked', 'd': 'D', 'm': 'M', 'y': 'Y',
    'daysGranted': 'Days Granted', 'vacationDue': 'Vacation Due', 'dueToEmployee': 'Due To Employee',
    'deductions': 'Deduction', 'col.benefit': 'Benefits Description', 'col.from': 'From Period',
    'col.to': 'To Period', 'col.actual': 'Actual', 'col.due': 'Due Amount', 'col.deduction': 'Deduction Description',
    'col.amount': 'Amount', 'col.paid': 'Paid To Date', 'col.balance': 'Balance', 'totalDue': 'Total Due',
    'totalOwed': 'Total Owed', 'finalAmount': 'Final Amount', 'sign.hrd': 'HRD', 'sign.overtime': 'Overtime Admin',
    'sign.payroll': 'Payroll Admin', 'sign.finance': 'Finance', 'sign.admin': 'Admin',
    'clearanceTitle': 'Clearance of Liability',
    'declaration': 'I, the undersigned, {name}, acknowledge that I have received from {company} all the leave settlement amounts shown above. I sign to confirm this.',
    'received': 'Received', 'signature': 'Signature', 'printedBy': 'Printed By', 'retrievalDate': 'Date of Retrieval',
    'docControl': 'Document Control No.', 'page': 'Page 1 of 1',
  };

  static const _ar = {
    'title': 'تسوية إجازة موظف', 'date': 'التاريخ', 'empNo': 'رقم الموظف', 'iqama': 'الإقامة/البطاقة',
    'empName': 'اسم الموظف', 'department': 'الإدارة', 'section': 'القسم', 'position': 'الوظيفة',
    'nationality': 'الجنسية', 'leaveType': 'مسمى الإجازة', 'workFrom': 'بداية فترة', 'workTo': 'العمل إلى تاريخ',
    'employmentStart': 'تاريخ التعيين', 'basicSalary': 'الراتب الأساسي', 'vacationStart': 'تاريخ بداية الإجازة',
    'vacationEnd': 'تاريخ نهاية الإجازة', 'periodWorked': 'فترة العمل', 'd': 'ي', 'm': 'ش', 'y': 'س',
    'daysGranted': 'الأيام الممنوحة', 'vacationDue': 'الإجازة المستحقة', 'dueToEmployee': 'المستحق للموظف',
    'deductions': 'الاستقطاعات', 'col.benefit': 'وصف المزايا', 'col.from': 'من فترة', 'col.to': 'إلى فترة',
    'col.actual': 'الفعلي', 'col.due': 'المبلغ المستحق', 'col.deduction': 'وصف الاستقطاع', 'col.amount': 'المبلغ',
    'col.paid': 'المدفوع حتى التاريخ', 'col.balance': 'الرصيد', 'totalDue': 'إجمالي المستحق',
    'totalOwed': 'إجمالي المديونية', 'finalAmount': 'المبلغ النهائي', 'sign.hrd': 'الموارد البشرية',
    'sign.overtime': 'مسؤول العمل الإضافي', 'sign.payroll': 'مسؤول الرواتب', 'sign.finance': 'المالية',
    'sign.admin': 'الإدارة', 'clearanceTitle': 'إبـراء ذمـة',
    'declaration': 'أنا الموقع أدناه {name} أقر وأعترف أنني استلمت من {company} جميع مبالغ تسوية الإجازة الموضحة أعلاه، وعلى ذلك أوقع.',
    'received': 'استلام', 'signature': 'التوقيع', 'printedBy': 'طبع بواسطة', 'retrievalDate': 'تاريخ الاسترجاع',
    'docControl': 'رقم التحكم بالوثيقة', 'page': 'صفحة 1 من 1',
  };

  static Map<String, dynamic> _m(dynamic v) => v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
  static List<Map<String, dynamic>> _l(dynamic v) =>
      v is List ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList() : [];
  static double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;

  static String _esc(dynamic v) => '${v ?? ''}'
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');

  /// 1234.5 → 1,234.50 (en-US, 2 decimals), as the web.
  static String amount(dynamic n) {
    final v = _d(n);
    final neg = v < 0;
    final parts = v.abs().toStringAsFixed(2).split('.');
    final b = StringBuffer();
    final s = parts[0];
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return '${neg ? '-' : ''}$b.${parts[1]}';
  }

  /// YYYY-MM-DD → DD-MM-YYYY; empty → N/A.
  static String day(dynamic v) {
    final s = '${v ?? ''}'.split(' ').first;
    final p = s.split('-');
    if (s.isEmpty) return 'N/A';
    return p.length == 3 ? '${p[2]}-${p[1]}-${p[0]}' : s;
  }

  static String _num(dynamic n) {
    final v = (_d(n) * 100).round() / 100;
    return v == v.roundToDouble() ? v.toInt().toString() : '$v';
  }

  static String _ltr(String v) => '<span dir="ltr">${_esc(v)}</span>';

  /// Totals as the web modal: entitlements = Σ benefits.due,
  /// deductions = Σ to_be_paid, net = entitlements − deductions.
  static ({double entitlements, double deductions, double net}) totals(Map<String, dynamic> s) {
    final e = _l(s['benefits']).fold<double>(0, (a, b) => a + _d(b['due']));
    final d = _l(s['deductions']).fold<double>(0, (a, x) => a + _d(x['to_be_paid']));
    return (entitlements: e, deductions: d, net: e - d);
  }

  static String html(Map<String, dynamic> s, {required bool rtl, String? reqNo}) {
    final t = rtl ? _ar : _en;
    String p(String k) => t[k] ?? k;
    final se = _m(s['employee']);
    final lv = _m(s['leave']);
    final worked = _m(lv['worked']);
    final header = _m(s['print']);
    final company = '${header['company'] ?? ''}';
    final name = '${se['name'] ?? ''}';
    final now = DateTime.now();
    final today =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
    final dir = rtl ? 'rtl' : 'ltr';
    final start = rtl ? 'right' : 'left';
    final end = rtl ? 'left' : 'right';
    final tot = totals(s);

    String row(List<String> a, [List<String>? b]) =>
        '<tr><td class="label-cell">${_esc(a[0])}:</td><td class="value-cell"${b != null ? '' : ' colspan="3"'}>${a[1]}</td>'
        '${b != null ? '<td class="label-cell">${_esc(b[0])}:</td><td class="value-cell">${b[1]}</td>' : ''}</tr>';

    final info = [
      row([p('empNo'), _esc(se['employee_no'])], [p('iqama'), _esc(se['iqama_no'] ?? 'N/A')]),
      row([p('empName'), _esc(name)]),
      row([p('department'), _esc(se['department'] ?? 'N/A')]),
      row([p('section'), _esc(se['section'] ?? 'N/A')]),
      row([p('position'), _esc(se['position'] ?? 'N/A')], [p('nationality'), _esc(se['nationality'] ?? 'N/A')]),
      row([p('leaveType'), _esc(lv['type'] ?? 'N/A')]),
      row([p('workFrom'), _ltr(day(lv['work_from']))], [p('workTo'), _ltr(day(lv['work_to']))]),
      row([p('employmentStart'), _ltr(day(se['contract_start'] ?? se['hire_date']))],
          [p('basicSalary'), _esc(amount(lv['monthly_salary']))]),
      row([p('vacationStart'), _ltr(day(lv['from']))], [p('vacationEnd'), _ltr(day(lv['to']))]),
      row([
        p('periodWorked'),
        '<span class="period-box">${_esc(worked['days'] ?? 0)} <small>${_esc(p('d'))}</small></span>'
            '<span class="period-box">${_esc(worked['months'] ?? 0)} <small>${_esc(p('m'))}</small></span>'
            '<span class="period-box">${_esc(worked['years'] ?? 0)} <small>${_esc(p('y'))}</small></span>'
      ], [p('daysGranted'), _esc(_num(lv['grant_days'] ?? lv['days']))]),
      '<tr><td class="label-cell">${_esc(p('vacationDue'))}:</td><td class="value-cell">${_esc(_num(lv['due_days']))}</td><td class="label-cell"></td><td class="value-cell"></td></tr>',
    ].join();

    final benefits = _l(s['benefits']);
    var i = 0;
    final benefitRows = benefits.map((b) {
      i++;
      return '<tr><td class="text-center">$i</td><td>${_esc(b['desc'])}</td>'
          '<td class="text-center">${_ltr(day(b['from']))}</td><td class="text-center">${_ltr(day(b['to']))}</td>'
          '<td class="num">${amount(b['net'])}</td><td class="num">${amount(b['due'])}</td></tr>';
    }).join();

    // deductions: the whole deduction, already paid, deducted in this settlement (to_be_paid)
    final deductions = _l(s['deductions']);
    var j = 0;
    final deductionRows = deductions.map((d) {
      j++;
      final total = _d(d['amount']);
      final toPay = _d(d['to_be_paid']);
      final paid = (total - toPay) < 0 ? 0 : total - toPay;
      return '<tr><td class="text-center">${j.toString().padLeft(3, '0')}</td><td>${_esc(d['name'])}</td>'
          '<td class="num">${amount(total)}</td><td class="num">${amount(paid)}</td><td class="num">${amount(toPay)}</td></tr>';
    }).join();

    final declaration = p('declaration')
        .replaceAll('{name}', '<strong>${_esc(name)}</strong>')
        .replaceAll('{company}', _esc(company));

    return '''<!DOCTYPE html><html lang="${rtl ? 'ar' : 'en'}" dir="$dir"><head><meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<title>${_esc(p('title'))}${reqNo != null && reqNo.isNotEmpty ? ' | REQ-${_esc(reqNo)}' : ''}</title><style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { font-family: Arial, sans-serif; font-size: 10pt; padding: 25px 50px; background: #fff; color: #000; }
  .header { text-align: center; margin-bottom: 15px; }
  .company { font-size: 11pt; margin-bottom: 8px; font-weight: bold; }
  .doc-title { font-size: 11pt; margin-bottom: 15px; font-weight: bold; }
  .outer-box { border: 1.5px solid #000; padding: 12px; margin-bottom: 5px; }
  .date-line { font-size: 10pt; margin-bottom: 10px; }
  .info-table { width: 100%; border-collapse: collapse; }
  .info-table td { border: 1px solid #000; padding: 3px 8px; font-size: 9.5pt; }
  .info-table .label-cell { background-color: #E5E5E5; text-align: $end; width: 23%; }
  .info-table .value-cell { background-color: #fff; text-align: $start; font-weight: bold; width: 27%; }
  .section-heading { font-size: 10pt; margin: 12px 0 8px 0; font-weight: bold; }
  .benefits-table, .deduction-table { width: 100%; border-collapse: collapse; margin-bottom: 15px; }
  .benefits-table th, .deduction-table th { border: 1px solid #000; background-color: #D5D5D5; padding: 4px 6px; font-size: 9pt; font-weight: normal; text-align: center; }
  .benefits-table td, .deduction-table td { border: 1px solid #000; padding: 4px 6px; font-size: 9pt; }
  .text-center { text-align: center; }
  .num { text-align: $end; }
  .gap { height: 30px; }
  .amount-row { display: flex; justify-content: space-between; align-items: center; margin: 12px 0; font-size: 10pt; }
  .final-amount { border-bottom: 1px solid #000; padding-bottom: 2px; min-width: 280px; text-align: $end; font-weight: bold; }
  .signature-bar { margin: 28px 0 35px 0; display: flex; justify-content: space-between; gap: 20px; }
  .sig-item { text-align: center; font-size: 9pt; border-top: 1px solid #000; padding-top: 4px; flex: 1; }
  .clearance-title { text-align: center; font-size: 11pt; font-weight: bold; margin-bottom: 8px; }
  .declaration { font-size: 9.5pt; margin-bottom: 30px; line-height: 1.5; text-align: justify; }
  .sig-line { padding-top: 4px; display: flex; justify-content: space-between; margin-top: 10px; gap: 250px; }
  .sig-label { font-size: 9pt; border-top: 1px solid #000; padding-top: 4px; flex: 1; text-align: center; }
  .footer-section { border-top: 1px solid #000; padding-top: 8px; margin-top: 25px; font-size: 8.5pt; }
  .footer-line { display: flex; justify-content: space-between; margin-bottom: 2px; }
  .period-box { display: inline-block; border: 1px solid #000; padding: 2px 8px; margin: 0 3px; border-radius: 3px; }
  .period-box small { font-size: 0.85em; color: #666; margin-inline-start: 2px; }
  @media print { @page { margin: 10mm; } body { padding: 0; } }
</style></head><body>
  <div class="header">
    <div class="company">${_esc(company)}${header['branch'] != null && '${header['branch']}'.isNotEmpty ? ' - ${_esc(header['branch'])}' : ''}</div>
    <div class="doc-title">${_esc(p('title'))}</div>
  </div>
  <div class="outer-box">
    <div class="date-line">${_esc(p('date'))}: &nbsp;&nbsp;${_ltr(today)}</div>
    <table class="info-table">$info</table>
  </div>
  <div class="section-heading">${_esc(p('dueToEmployee'))}</div>
  <table class="benefits-table">
    <thead><tr>
      <th style="width:6%">#</th><th style="width:42%">${_esc(p('col.benefit'))}</th><th style="width:13%">${_esc(p('col.from'))}</th>
      <th style="width:13%">${_esc(p('col.to'))}</th><th style="width:13%">${_esc(p('col.actual'))}</th><th style="width:13%">${_esc(p('col.due'))}</th>
    </tr></thead>
    <tbody>$benefitRows
      <tr><td colspan="5" class="num"><strong>${_esc(p('totalDue'))}</strong></td><td class="num"><strong>${amount(tot.entitlements)}</strong></td></tr>
    </tbody>
  </table>
  ${deductions.isNotEmpty ? '''<div class="gap"></div>
  <div class="section-heading">${_esc(p('deductions'))}</div>
  <table class="deduction-table">
    <thead><tr>
      <th style="width:7%">#</th><th style="width:49%">${_esc(p('col.deduction'))}</th><th style="width:15%">${_esc(p('col.amount'))}</th>
      <th style="width:15%">${_esc(p('col.paid'))}</th><th style="width:14%">${_esc(p('col.balance'))}</th>
    </tr></thead>
    <tbody>$deductionRows
      <tr><td colspan="4" class="num"><strong>${_esc(p('totalOwed'))}</strong></td><td class="num"><strong>${amount(tot.deductions)}</strong></td></tr>
    </tbody>
  </table>''' : ''}
  <div class="amount-row"><span>&nbsp;</span>
    <span class="final-amount">${_esc(p('finalAmount'))}: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;${amount(tot.net)}</span>
  </div>
  <div class="signature-bar">${['hrd', 'overtime', 'payroll', 'finance', 'admin'].map((k) => '<div class="sig-item">${_esc(p('sign.$k'))}</div>').join()}</div>
  <div class="clearance-title">${_esc(p('clearanceTitle'))}</div>
  <div class="declaration">$declaration</div>
  <div class="sig-line"><div class="sig-label">${_esc(p('received'))}</div><div class="sig-label">${_esc(p('signature'))}</div></div>
  <div class="footer-section">
    <div class="footer-line"><span>${_esc(p('printedBy'))}: &nbsp;&nbsp;${_esc(header['printed_by'])}</span><span>${_esc(p('retrievalDate'))}: &nbsp;&nbsp;${_ltr(today)}</span></div>
    <div class="footer-line"><span>${_esc(p('docControl'))}: HR018</span><span>${_esc(p('page'))}</span></div>
  </div>
</body></html>''';
  }

  /// Opens the phone's print dialog (print or save as PDF) for this settlement.
  static Future<void> printIt(Map<String, dynamic> s, {required bool rtl, String? reqNo}) {
    final doc = html(s, rtl: rtl, reqNo: reqNo);
    return Printing.layoutPdf(
      name: 'leave_settlement${reqNo != null ? '_$reqNo' : ''}',
      onLayout: (format) => Printing.convertHtml(format: format, html: doc),
    );
  }
}
