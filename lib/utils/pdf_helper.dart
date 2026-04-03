// lib/utils/pdf_helper.dart

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/models/report_model.dart';

class PdfHelper {
  static pw.Font? _cachedRegular;
  static pw.Font? _cachedBold;

  // ─── تحميل الخطوط من assets (مرة واحدة فقط) ─────────────────────────────
  static Future<void> _loadFonts() async {
    if (_cachedRegular != null) return;
    final regular = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
    final bold    = await rootBundle.load('assets/fonts/Cairo-Bold.ttf');
    _cachedRegular = pw.Font.ttf(regular);
    _cachedBold    = pw.Font.ttf(bold);
  }

  // ─── Entry point ─────────────────────────────────────────────────────────
  static Future<void> exportReport(ReportModel report) async {
    await _loadFonts();
    final pdf = _buildPdf(report);
    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: '${report.title}.pdf',
    );
  }

  // ─── Build document ───────────────────────────────────────────────────────
  static pw.Document _buildPdf(ReportModel report) {
    final regular = _cachedRegular!;
    final bold    = _cachedBold!;

    final theme = pw.ThemeData.withFont(base: regular, bold: bold);
    final doc   = pw.Document(theme: theme);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 40),
        header: (_) => _buildHeader(report, bold, regular),
        footer: (_) => _buildFooter(regular),
        build: (ctx) => [
          pw.SizedBox(height: 16),
          _buildMeta(report, regular, bold),
          pw.SizedBox(height: 20),
          pw.Divider(thickness: 0.5, color: PdfColors.grey300),
          pw.SizedBox(height: 16),
          ..._buildBody(report, regular, bold),
        ],
      ),
    );
    return doc;
  }

  // ─── Header ───────────────────────────────────────────────────────────────
  static pw.Widget _buildHeader(ReportModel report, pw.Font bold, pw.Font regular) {
    final typeColors = <String, PdfColor>{
      'attendance': PdfColor.fromHex('F59E0B'),
      'performance': PdfColor.fromHex('3B82F6'),
      'financial': PdfColor.fromHex('10B981'),
    };
    final color = typeColors[report.type] ?? PdfColor.fromHex('6B7280');

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(report.title,
                  style: pw.TextStyle(font: bold, fontSize: 16, color: PdfColors.white)),
              pw.SizedBox(height: 5),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(20),
                ),
                child: pw.Text(report.typeLabel,
                    style: pw.TextStyle(font: bold, fontSize: 9, color: color)),
              ),
            ],
          ),
          pw.Text('معهد النور',
              style: pw.TextStyle(font: regular, fontSize: 12, color: PdfColor.fromInt(0xB3FFFFFF))),
        ],
      ),
    );
  }

  // ─── Meta ─────────────────────────────────────────────────────────────────
  static pw.Widget _buildMeta(ReportModel report, pw.Font regular, pw.Font bold) {
    return pw.Row(
      children: [
        _metaBox('الفترة',
            '${_fmt(report.periodStart)} — ${_fmt(report.periodEnd)}',
            regular, bold),
        pw.SizedBox(width: 12),
        _metaBox('تاريخ الإنشاء', _fmt(report.generatedAt), regular, bold),
      ],
    );
  }

  static pw.Widget _metaBox(String label, String value, pw.Font regular, pw.Font bold) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('F5F7FA'),
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: PdfColor.fromHex('E5E7EB'), width: 0.5),
        ),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(label,
              style: pw.TextStyle(font: regular, fontSize: 8, color: PdfColors.grey600)),
          pw.SizedBox(height: 3),
          pw.Text(value,
              style: pw.TextStyle(font: bold, fontSize: 10)),
        ]),
      ),
    );
  }

  // ─── Footer ───────────────────────────────────────────────────────────────
  static pw.Widget _buildFooter(pw.Font regular) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      child: pw.Divider(thickness: 0.3, color: PdfColors.grey300),
    );
  }

  // ─── Body dispatcher ──────────────────────────────────────────────────────
  static List<pw.Widget> _buildBody(ReportModel report, pw.Font regular, pw.Font bold) {
    switch (report.type) {
      case 'attendance':  return _attendanceBody(report.data, regular, bold);
      case 'financial':   return _financialBody(report.data, regular, bold);
      case 'performance':
      // التقرير الشهري يحتوي على مفتاح 'reports'
        if (report.data.containsKey('reports')) {
          return _monthlyBody(report.data, regular, bold);
        }
        return _performanceBody(report.data, regular, bold);
      default: return [];
    }
  }

  // ─── Attendance ───────────────────────────────────────────────────────────
  static List<pw.Widget> _attendanceBody(
      Map<String, dynamic> d, pw.Font regular, pw.Font bold) {
    final totalStudents = d['totalStudents'] ?? 0;
    final summary       = d['summary']       as List? ?? [];
    final topAbsentees  = d['topAbsentees']  as List? ?? [];

    return [
      _sectionTitle('ملخص الحضور', bold),
      pw.SizedBox(height: 8),
      _kvTable([
        ['إجمالي الطلاب',         '$totalStudents'],
        ['عدد الأيام المسجلة',    '${summary.length}'],
        ['حالات الغياب البارزة',  '${topAbsentees.length}'],
      ], regular, bold),
      if (topAbsentees.isNotEmpty) ...[
        pw.SizedBox(height: 20),
        _sectionTitle('أكثر الطلاب غياباً', bold),
        pw.SizedBox(height: 8),
        _dataTable(
          headers: ['اسم الطالب', 'عدد أيام الغياب'],
          rows: topAbsentees.map((s) => [
            s['studentName']?.toString() ?? '—',
            '${s['absentCount'] ?? 0} يوم',
          ]).toList(),
          regular: regular, bold: bold,
        ),
      ] else ...[
        pw.SizedBox(height: 12),
        _emptyNote('لم يُسجل أي غياب في هذه الفترة', regular),
      ],
    ];
  }

  // ─── Financial ────────────────────────────────────────────────────────────
  static List<pw.Widget> _financialBody(
      Map<String, dynamic> d, pw.Font regular, pw.Font bold) {
    final income   = _toDouble(d['totalIncome']);
    final expenses = _toDouble(d['totalExpenses']);
    final net      = _toDouble(d['netProfit']);
    final byStatus = d['paymentsByStatus']   as List? ?? [];
    final byCat    = d['expensesByCategory'] as List? ?? [];

    return [
      _sectionTitle('الملخص المالي', bold),
      pw.SizedBox(height: 8),
      _kvTable([
        ['إجمالي الدخل',     _fmtCurrency(income)],
        ['إجمالي المصروفات', _fmtCurrency(expenses)],
        ['صافي الربح',        _fmtCurrency(net)],
      ], regular, bold),
      if (byStatus.isNotEmpty) ...[
        pw.SizedBox(height: 20),
        _sectionTitle('المدفوعات حسب الحالة', bold),
        pw.SizedBox(height: 8),
        _dataTable(
          headers: ['الحالة', 'العدد', 'الإجمالي'],
          rows: byStatus.map((s) {
            final sum = _toDouble(s['_sum']?['finalAmount']);
            return [
              _statusLabel(s['status']?.toString() ?? ''),
              '${s['_count'] ?? 0}',
              _fmtCurrency(sum),
            ];
          }).toList(),
          regular: regular, bold: bold,
        ),
      ],
      if (byCat.isNotEmpty) ...[
        pw.SizedBox(height: 20),
        _sectionTitle('المصروفات حسب الفئة', bold),
        pw.SizedBox(height: 8),
        _dataTable(
          headers: ['الفئة', 'المبلغ'],
          rows: byCat.map((c) {
            final amt = _toDouble(c['_sum']?['amount']);
            return [_categoryLabel(c['category']?.toString() ?? ''), _fmtCurrency(amt)];
          }).toList(),
          regular: regular, bold: bold,
        ),
      ],
    ];
  }


  // ─── Monthly Report ───────────────────────────────────────────────────────
  static List<pw.Widget> _monthlyBody(
      Map<String, dynamic> d, pw.Font regular, pw.Font bold) {
    final period  = d['period']  as Map<String, dynamic>? ?? {};
    final reports = d['reports'] as List? ?? [];

    final widgets = <pw.Widget>[];

    // Header الفترة
    widgets.add(
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('EFF6FF'),
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: PdfColor.fromHex('BFDBFE'), width: 0.5),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('تقرير شهري — ${period['monthName'] ?? ''} ${period['year'] ?? ''}',
                style: pw.TextStyle(font: bold, fontSize: 11, color: PdfColor.fromHex('1D4ED8'))),
            pw.Text('${reports.length} طالب',
                style: pw.TextStyle(font: regular, fontSize: 9, color: PdfColor.fromHex('3B82F6'))),
          ],
        ),
      ),
    );
    widgets.add(pw.SizedBox(height: 16));

    if (reports.isEmpty) {
      widgets.add(_emptyNote('لا توجد تقييمات لهذا الشهر', regular));
      return widgets;
    }

    for (final r in reports) {
      final student     = r['student']     as Map<String, dynamic>? ?? {};
      final assessments = r['assessments'] as List? ?? [];
      final summary     = r['summary']     as Map<String, dynamic>? ?? {};
      final avgPct      = summary['averagePercentage'];
      final grade       = summary['overallGrade']?.toString() ?? '—';
      final name        = student['name']?.toString() ?? '—';
      final section     = student['section']?.toString() ?? '';

      // اسم الطالب + ملخص
      widgets.add(
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('F8FAFC'),
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColor.fromHex('E2E8F0'), width: 0.5),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(name, style: pw.TextStyle(font: bold, fontSize: 11)),
                  pw.SizedBox(height: 2),
                  pw.Text(section,
                      style: pw.TextStyle(font: regular, fontSize: 9,
                          color: PdfColors.grey600)),
                ],
              ),
              if (avgPct != null)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('${(avgPct as num).toStringAsFixed(1)}%',
                        style: pw.TextStyle(font: bold, fontSize: 13,
                            color: PdfColor.fromHex('1D4ED8'))),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('DBEAFE'),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(grade,
                          style: pw.TextStyle(font: bold, fontSize: 8,
                              color: PdfColor.fromHex('1D4ED8'))),
                    ),
                  ],
                )
              else
                pw.Text('لا تقييمات',
                    style: pw.TextStyle(font: regular, fontSize: 9,
                        color: PdfColors.grey400)),
            ],
          ),
        ),
      );

      // جدول التقييمات
      if (assessments.isNotEmpty) {
        widgets.add(pw.SizedBox(height: 6));
        widgets.add(
          _dataTable(
            headers: ['المادة', 'النوع', 'الدرجة', 'التقدير', 'التاريخ'],
            rows: assessments.map((a) => [
              a['subject']?.toString() ?? '—',
              a['type']?.toString() ?? '—',
              '${a['score'] ?? '—'}/${a['maxScore'] ?? '—'}',
              a['grade']?.toString() ?? '—',
              _fmt(a['date']?.toString()),
            ]).toList(),
            regular: regular,
            bold: bold,
          ),
        );
      } else {
        widgets.add(pw.SizedBox(height: 4));
        widgets.add(_emptyNote('لا توجد تقييمات لهذا الطالب في هذا الشهر', regular));
      }

      widgets.add(pw.SizedBox(height: 14));
    }

    return widgets;
  }

  // ─── Performance ──────────────────────────────────────────────────────────
  static List<pw.Widget> _performanceBody(
      Map<String, dynamic> d, pw.Font regular, pw.Font bold) {
    final avg  = d['averageScores']    as List? ?? [];
    final dist = d['gradeDistribution'] as List? ?? [];

    return [
      if (avg.isNotEmpty) ...[
        _sectionTitle('متوسط الدرجات حسب المادة', bold),
        pw.SizedBox(height: 8),
        _dataTable(
          headers: ['المادة', 'المتوسط', 'عدد التقييمات'],
          rows: avg.map((s) {
            final pct   = s['_avg']?['percentage'] ?? 0;
            final count = s['_count'] ?? 0;
            return ['مادة #${s['gradeSubjectId']}', '$pct%', '$count'];
          }).toList(),
          regular: regular, bold: bold,
        ),
      ],
      if (dist.isNotEmpty) ...[
        pw.SizedBox(height: 20),
        _sectionTitle('توزيع الدرجات', bold),
        pw.SizedBox(height: 8),
        _dataTable(
          headers: ['التقدير', 'عدد الطلاب'],
          rows: dist.map((g) => [
            g['grade']?.toString() ?? '—',
            '${g['_count'] ?? 0} طالب',
          ]).toList(),
          regular: regular, bold: bold,
        ),
      ],
    ];
  }

  // ─── Shared widgets ───────────────────────────────────────────────────────
  static pw.Widget _sectionTitle(String title, pw.Font bold) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      child: pw.Text(title,
          style: pw.TextStyle(font: bold, fontSize: 12, color: PdfColors.grey800)),
    );
  }

  // Key-Value table (2 columns)
  static pw.Widget _kvTable(
      List<List<String>> rows, pw.Font regular, pw.Font bold) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('E5E7EB'), width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1),
      },
      children: rows.map((row) {
        return pw.TableRow(
          decoration: pw.BoxDecoration(
            color: rows.indexOf(row).isEven
                ? PdfColor.fromHex('F9FAFB')
                : PdfColors.white,
          ),
          children: [
            _cell(row[0], regular, align: pw.TextAlign.right),
            _cell(row[1], bold,    align: pw.TextAlign.center),
          ],
        );
      }).toList(),
    );
  }

  // Generic data table
  static pw.Widget _dataTable({
    required List<String> headers,
    required List<List<String>> rows,
    required pw.Font regular,
    required pw.Font bold,
  }) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('E5E7EB'), width: 0.5),
      children: [
        // Header row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('F3F4F6')),
          children: headers
              .map((h) => _cell(h, bold, isHeader: true))
              .toList(),
        ),
        // Data rows
        ...rows.asMap().entries.map((entry) {
          final isEven = entry.key.isEven;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEven ? PdfColors.white : PdfColor.fromHex('F9FAFB'),
            ),
            children: entry.value.map((cell) => _cell(cell, regular)).toList(),
          );
        }),
      ],
    );
  }

  static pw.Widget _cell(String text, pw.Font font,
      {bool isHeader = false,
        pw.TextAlign align = pw.TextAlign.right}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 10 : 9,
          color: isHeader ? PdfColors.grey800 : PdfColors.grey700,
        ),
      ),
    );
  }

  static pw.Widget _emptyNote(String msg, pw.Font regular) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('FEF9C3'),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColor.fromHex('FDE047'), width: 0.5),
      ),
      child: pw.Text(msg,
          style: pw.TextStyle(font: regular, fontSize: 10, color: PdfColors.grey700)),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  static String _fmt(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      final d = DateTime.parse(iso);
      return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
    } catch (_) { return iso; }
  }

  static double _toDouble(dynamic v) =>
      v is num ? v.toDouble() : 0.0;

  static String _fmtCurrency(double v) {
    final s = v.toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
    return '$s د.ع';
  }

  static String _statusLabel(String s) {
    const m = {'paid': 'مدفوع', 'pending': 'معلق', 'partial': 'جزئي'};
    return m[s] ?? s;
  }

  static String _categoryLabel(String s) {
    const m = {
      'salary': 'رواتب', 'maintenance': 'صيانة',
      'supplies': 'مستلزمات', 'utilities': 'خدمات', 'other': 'أخرى',
    };
    return m[s] ?? s;
  }
}