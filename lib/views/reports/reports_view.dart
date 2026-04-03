import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/report_controller.dart';
import '../../controllers/locale_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/empty_widget.dart' hide ErrorWidget;
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_button.dart';
import '../../data/models/report_model.dart';
import '../../utils/pdf_helper.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          title: Text('reports_title'.tr,
              style:
              AppTextStyles.titleMedium.copyWith(color: Colors.white)),
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () => _showCreateSheet(context, controller),
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            labelStyle: AppTextStyles.labelMedium
                .copyWith(fontWeight: FontWeight.w700),
            unselectedLabelStyle: AppTextStyles.labelMedium,
            tabs: [
              Tab(text: 'reports_general'.tr),
              Tab(text: 'reports_monthly'.tr),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _GeneralReportsTab(controller: controller),
            _MonthlyReportsTab(controller: controller),
          ],
        ),
      ),
    );
  }

  void _showCreateSheet(
      BuildContext context, ReportController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateReportSheet(controller: controller),
    );
  }
}

// ==================== General Reports Tab ====================

class _GeneralReportsTab extends StatelessWidget {
  final ReportController controller;
  const _GeneralReportsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          itemBuilder: (_, __) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: ShimmerCard(),
          ),
        );
      }
      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: AppErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.loadAll,
          ),
        );
      }
      if (controller.reports.isEmpty) {
        return EmptyWidget(
          title: 'reports_empty'.tr,
          subtitle: 'reports_empty_sub'.tr,
          icon: Icons.description_outlined,
        );
      }
      return RefreshIndicator(
        onRefresh: controller.loadAll,
        color: AppColors.primary,
        child: ListView.builder(
          padding:
          const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          itemCount: controller.reports.length,
          itemBuilder: (_, i) => _ReportCard(
              report: controller.reports[i], controller: controller),
        ),
      );
    });
  }
}

// ==================== Monthly Reports Tab ====================

class _MonthlyReportsTab extends StatelessWidget {
  final ReportController controller;
  const _MonthlyReportsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(14),
              border:
              Border.all(color: AppColors.info.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: AppColors.info, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'reports_monthly_info'.tr,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('reports_select_period'.tr,
              style: AppTextStyles.titleSmall),
          const SizedBox(height: 10),
          _MonthYearPicker(controller: controller),
          const SizedBox(height: 20),
          Text('reports_select_section'.tr,
              style: AppTextStyles.titleSmall),
          const SizedBox(height: 10),
          _SectionSelector(controller: controller),
          const SizedBox(height: 24),
          _ActionButtons(controller: controller),
          const SizedBox(height: 20),
          _MonthlyReportResult(controller: controller),
        ],
      ),
    );
  }
}

// ==================== Month Year Picker ====================

class _MonthYearPicker extends StatelessWidget {
  final ReportController controller;
  const _MonthYearPicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('reports_month'.tr,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.grey500)),
                const SizedBox(height: 6),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: controller.selectedMonth.value,
                      isExpanded: true,
                      style: AppTextStyles.bodyMedium,
                      dropdownColor: scheme.surface,
                      items: List.generate(
                          12,
                              (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text(
                                AppConstants.getMonthName(i + 1)),
                          )),
                      onChanged: (v) {
                        if (v != null)
                          controller.selectedMonth.value = v;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('reports_year'.tr,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.grey500)),
                const SizedBox(height: 6),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: controller.selectedYear.value,
                      isExpanded: true,
                      style: AppTextStyles.bodyMedium,
                      dropdownColor: scheme.surface,
                      items: List.generate(5, (i) {
                        final year = DateTime.now().year - 2 + i;
                        return DropdownMenuItem(
                            value: year, child: Text('$year'));
                      }),
                      onChanged: (v) {
                        if (v != null)
                          controller.selectedYear.value = v;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

// ==================== Section Selector ====================

class _SectionSelector extends StatelessWidget {
  final ReportController controller;
  const _SectionSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      if (controller.isSectionsLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.sections.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(12)),
          child: Text('reports_no_active_sections'.tr,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.warning)),
        );
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: controller.selectedSectionId.value,
            isExpanded: true,
            dropdownColor: scheme.surface,
            hint: Text('reports_section_hint'.tr,
                style: AppTextStyles.inputHint),
            style: AppTextStyles.bodyMedium,
            items: controller.sections
                .map((s) => DropdownMenuItem(
                value: s.id, child: Text(s.fullName)))
                .toList(),
            onChanged: (v) => controller.selectedSectionId.value = v,
          ),
        ),
      );
    });
  }
}

// ==================== Action Buttons ====================

class _ActionButtons extends StatelessWidget {
  final ReportController controller;
  const _ActionButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasSection = controller.selectedSectionId.value != null;
      return Column(
        children: [
          CustomButton(
            label: 'reports_view_monthly'.tr,
            icon: Icons.visibility_outlined,
            type: ButtonType.outlined,
            isLoading: controller.isMonthlyLoading.value,
            onPressed: hasSection
                ? () => controller.loadMonthlySectionReport(
                controller.selectedSectionId.value!,
                controller.selectedMonth.value,
                controller.selectedYear.value)
                : null,
          ),
          const SizedBox(height: 10),
          CustomButton(
            label: 'reports_send_section'.tr,
            icon: Icons.send_outlined,
            isLoading: controller.isMonthlySubmitting.value,
            onPressed: hasSection
                ? () async {
              final monthName = controller
                  .monthName(controller.selectedMonth.value);
              final confirmed =
              await Helpers.showConfirmDialog(
                title: 'reports_send_confirm_title'.tr,
                message: 'reports_send_confirm_msg'.tr
                    .replaceAll('@month', monthName),
                confirmText: 'reports_send_confirm_button'.tr,
              );
              if (confirmed == true) {
                controller.sendMonthlySectionReport(
                    controller.selectedSectionId.value!,
                    controller.selectedMonth.value,
                    controller.selectedYear.value);
              }
            }
                : null,
          ),
          const SizedBox(height: 10),
          CustomButton(
            label: 'reports_send_all'.tr,
            icon: Icons.campaign_outlined,
            type: ButtonType.danger,
            isLoading: controller.isMonthlySubmitting.value,
            onPressed: () async {
              final monthName =
              controller.monthName(controller.selectedMonth.value);
              final confirmed = await Helpers.showConfirmDialog(
                title: 'reports_send_all_title'.tr,
                message: 'reports_send_all_msg'.tr
                    .replaceAll('@month', monthName)
                    .replaceAll(
                    '@year', '${controller.selectedYear.value}'),
                confirmText: 'reports_send_all_button'.tr,
                isDanger: true,
              );
              if (confirmed == true) {
                controller.sendMonthlyAllSections(
                    controller.selectedMonth.value,
                    controller.selectedYear.value);
              }
            },
          ),
        ],
      );
    });
  }
}

// ==================== Monthly Report Result ====================

class _MonthlyReportResult extends StatelessWidget {
  final ReportController controller;
  const _MonthlyReportResult({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = controller.monthlyData.value;
      if (data == null) return const SizedBox.shrink();

      final section =
          data['section'] as Map<String, dynamic>? ?? {};
      final period = data['period'] as Map<String, dynamic>? ?? {};
      final totalStudents = data['totalStudents'] ?? 0;
      final reports = data['reports'] as List? ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.85)
              ]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.bar_chart_rounded,
                    color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(section['name']?.toString() ?? '',
                          style: AppTextStyles.titleSmall
                              .copyWith(color: Colors.white)),
                      Text(
                          '${period['monthName'] ?? ''} ${period['year'] ?? ''}',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(
                      'attendance_student_count'.tr
                          .replaceAll('@count', '$totalStudents'),
                      style: AppTextStyles.labelSmall
                          .copyWith(color: Colors.white)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (reports.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.warning),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('reports_no_monthly_assessments'.tr,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.warning)),
                  ),
                ],
              ),
            )
          else
            ...reports
                .map((r) => _StudentReportCard(report: r)),
        ],
      );
    });
  }
}

// ==================== Student Report Card ====================

class _StudentReportCard extends StatelessWidget {
  final dynamic report;
  const _StudentReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final student =
        report['student'] as Map<String, dynamic>? ?? {};
    final assessments = report['assessments'] as List? ?? [];
    final summary =
        report['summary'] as Map<String, dynamic>? ?? {};
    final avgPct = summary['averagePercentage'];
    final overallGrade = summary['overallGrade'];
    final color = avgPct != null
        ? AppColors.getGradeColor(overallGrade?.toString())
        : AppColors.grey400;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(right: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Theme(
        data: Theme.of(context)
            .copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
          const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding:
          const EdgeInsets.fromLTRB(16, 0, 16, 12),
          title: Row(
            children: [
              InitialsAvatar(
                  name: student['name']?.toString() ?? '?',
                  size: 36,
                  color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student['name']?.toString() ?? '—',
                        style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600)),
                    Text(student['section']?.toString() ?? '',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.grey500)),
                  ],
                ),
              ),
              if (avgPct != null) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                        '${(avgPct as num).toStringAsFixed(1)}%',
                        style: AppTextStyles.titleSmall
                            .copyWith(color: color)),
                    StatusBadge(
                        label:
                        overallGrade?.toString() ?? '—',
                        color: color),
                  ],
                ),
              ] else
                Text('reports_no_assessments'.tr,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.grey400)),
            ],
          ),
          children: [
            if (assessments.isEmpty)
              Text('reports_no_monthly_assessments'.tr,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.grey400))
            else
              ...assessments.map((a) {
                final score = a['score'];
                final maxScore = a['maxScore'];
                final grade = a['grade'];
                final aColor = grade != null
                    ? AppColors.getGradeColor(grade.toString())
                    : AppColors.grey400;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            color: aColor.withOpacity(0.1),
                            borderRadius:
                            BorderRadius.circular(8)),
                        child: Icon(
                            a['type'] == 'مذاكرة' ||
                                a['type'] == 'midterm'
                                ? Icons.quiz_outlined
                                : Icons.assignment_outlined,
                            color: aColor,
                            size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                                a['subject']?.toString() ??
                                    '—',
                                style: AppTextStyles.bodyMedium
                                    .copyWith(
                                    fontWeight:
                                    FontWeight.w600,
                                    fontSize: 13)),
                            Row(
                              children: [
                                StatusBadge(
                                    label: a['type']
                                        ?.toString() ??
                                        '',
                                    color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                    Helpers.formatDate(
                                        a['date']?.toString() ??
                                            ''),
                                    style: AppTextStyles
                                        .bodySmall
                                        .copyWith(
                                        color:
                                        AppColors.grey500,
                                        fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (score != null)
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.end,
                          children: [
                            Text('$score/$maxScore',
                                style: AppTextStyles.labelMedium
                                    .copyWith(color: aColor)),
                            if (grade != null)
                              Text(grade.toString(),
                                  style: AppTextStyles.labelSmall
                                      .copyWith(
                                      color: aColor,
                                      fontWeight:
                                      FontWeight.w700)),
                          ],
                        )
                      else
                        Text('—',
                            style: AppTextStyles.bodySmall
                                .copyWith(
                                color: AppColors.grey400)),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

// ==================== Report Card ====================

class _ReportCard extends StatelessWidget {
  final ReportModel report;
  final ReportController controller;
  const _ReportCard(
      {required this.report, required this.controller});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final typeColors = <String, Color>{
      'attendance': AppColors.warning,
      'performance': AppColors.primary,
      'financial': AppColors.success,
    };
    final typeIcons = <String, IconData>{
      'attendance': Icons.fact_check_outlined,
      'performance': Icons.bar_chart_outlined,
      'financial': Icons.account_balance_wallet_outlined,
    };
    final color = typeColors[report.type] ?? AppColors.grey400;
    final icon =
        typeIcons[report.type] ?? Icons.description_outlined;

    return GestureDetector(
      onTap: () => _showDetails(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border(right: BorderSide(color: color, width: 4)),
          boxShadow: [
            BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(report.title,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(children: [
                    StatusBadge(
                        label: AppConstants.getReportType(
                            report.type),
                        color: color),
                    const SizedBox(width: 8),
                    Text(
                        Helpers.formatDate(
                            report.generatedAt ?? ''),
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.grey500)),
                  ]),
                  if (report.periodStart != null &&
                      report.periodEnd != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${Helpers.formatDate(report.periodStart!)} — ${Helpers.formatDate(report.periodEnd!)}',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.grey400),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  color: AppColors.error, size: 20),
              onPressed: () =>
                  controller.deleteReport(report.id),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReportDetailSheet(report: report),
    );
  }
}

// ==================== Report Detail Sheet ====================

class _ReportDetailSheet extends StatelessWidget {
  final ReportModel report;
  const _ReportDetailSheet({required this.report});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(report.title,
                        style: AppTextStyles.titleMedium
                            .copyWith(color: scheme.onSurface)),
                  ),
                  StatusBadge(
                      label: AppConstants.getReportType(report.type),
                      color: AppColors.primary),
                  const SizedBox(width: 8),
                  _ExportButton(report: report),
                ],
              ),
            ),
            Divider(color: AppColors.border),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'report_detail_period'.tr,
                    value:
                    '${Helpers.formatDate(report.periodStart ?? '')} — ${Helpers.formatDate(report.periodEnd ?? '')}',
                  ),
                  InfoRow(
                    icon: Icons.access_time_outlined,
                    label: 'report_detail_created'.tr,
                    value:
                    Helpers.formatDate(report.generatedAt ?? ''),
                  ),
                  const SizedBox(height: 16),
                  ..._buildDataSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDataSection(BuildContext context) {
    if (report.type == 'attendance')
      return _buildAttendanceData(context);
    if (report.type == 'financial')
      return _buildFinancialData(context);
    if (report.type == 'performance') {
      if (report.data.containsKey('reports'))
        return _buildMonthlyData(context);
      return _buildPerformanceData(context);
    }
    return [];
  }

  List<Widget> _buildMonthlyData(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final d = report.data;
    final period = d['period'] as Map<String, dynamic>? ?? {};
    final reports = d['reports'] as List? ?? [];

    return [
      Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.85)
          ]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.bar_chart_rounded,
                color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('reports_monthly_report'.tr,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Cairo',
                          fontSize: 14)),
                  Text(
                      '${period['monthName'] ?? ''} ${period['year'] ?? ''}',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Cairo',
                          fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8)),
              child: Text('${reports.length} ${'student'.tr}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Cairo',
                      fontSize: 12)),
            ),
          ],
        ),
      ),
      if (reports.isEmpty)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(12)),
          child: Text(
              'report_detail_no_monthly_assessments'.tr,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.warning)),
        )
      else
        ...reports
            .map<Widget>((r) => _StudentReportCard(report: r)),
    ];
  }

  List<Widget> _buildAttendanceData(BuildContext context) {
    final d = report.data;
    final totalStudents = d['totalStudents'] ?? 0;
    final summary = d['summary'] as List? ?? [];
    final topAbsentees = d['topAbsentees'] as List? ?? [];
    return [
      _sectionTitle('report_detail_attendance_summary'.tr),
      _dataCard(context, [
        _dataRow(context, 'report_detail_total_students'.tr,
            '$totalStudents'),
        _dataRow(context, 'report_detail_data_days'.tr,
            '${summary.length}'),
      ]),
      if (topAbsentees.isNotEmpty) ...[
        const SizedBox(height: 16),
        _sectionTitle('report_detail_top_absent'.tr),
        _dataCard(
            context,
            topAbsentees
                .map((s) => _dataRow(
                context,
                s['studentName']?.toString() ?? '—',
                'report_detail_absent_days'.tr.replaceAll(
                    '@count', '${s['absentCount'] ?? 0}')))
                .toList()),
      ],
    ];
  }

  List<Widget> _buildFinancialData(BuildContext context) {
    final d = report.data;
    final income = d['totalIncome'] ?? 0;
    final expenses = d['totalExpenses'] ?? 0;
    final net = d['netProfit'] ?? 0;
    return [
      _sectionTitle('report_detail_financial_summary'.tr),
      _dataCard(context, [
        _dataRow(
            context,
            'report_detail_total_income'.tr,
            Helpers.formatCurrency(
                income is num ? income.toDouble() : 0)),
        _dataRow(
            context,
            'report_detail_total_expenses'.tr,
            Helpers.formatCurrency(
                expenses is num ? expenses.toDouble() : 0)),
        _dataRow(
            context,
            'report_detail_net_profit'.tr,
            Helpers.formatCurrency(
                net is num ? net.toDouble() : 0)),
      ]),
    ];
  }

  List<Widget> _buildPerformanceData(BuildContext context) {
    final d = report.data;
    final avg = d['averageScores'] as List? ?? [];
    final dist = d['gradeDistribution'] as List? ?? [];
    return [
      if (avg.isNotEmpty) ...[
        _sectionTitle('report_detail_avg_scores'.tr),
        _dataCard(
            context,
            avg.map((s) {
              final pct = s['_avg']?['percentage'] ?? 0;
              final count = s['_count'] ?? 0;
              return _dataRow(
                  context,
                  'report_detail_subject_id'.tr
                      .replaceAll('@id', '${s['gradeSubjectId']}'),
                  'report_detail_assessment_count'.tr
                      .replaceAll('@pct', '$pct')
                      .replaceAll('@count', '$count'));
            }).toList()),
      ],
      if (dist.isNotEmpty) ...[
        const SizedBox(height: 16),
        _sectionTitle('report_detail_grade_distribution'.tr),
        _dataCard(
            context,
            dist
                .map((g) => _dataRow(
                context,
                g['grade']?.toString() ?? '—',
                'report_detail_student_count'.tr.replaceAll(
                    '@count', '${g['_count'] ?? 0}')))
                .toList()),
      ],
    ];
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title,
        style: AppTextStyles.titleSmall
            .copyWith(color: AppColors.textPrimary)),
  );

  Widget _dataCard(BuildContext context, List<Widget> rows) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: rows),
    );
  }

  Widget _dataRow(
      BuildContext context, String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.grey600)),
          Text(value,
              style: AppTextStyles.bodySmall.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ==================== Create Report Sheet ====================

class _CreateReportSheet extends StatefulWidget {
  final ReportController controller;
  const _CreateReportSheet({required this.controller});

  @override
  State<_CreateReportSheet> createState() =>
      _CreateReportSheetState();
}

class _CreateReportSheetState extends State<_CreateReportSheet> {
  String _type = 'attendance';
  final _titleController = TextEditingController();
  String? _start;
  String? _end;
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> get _types => [
    {
      'value': 'attendance',
      'label': 'report_type_attendance'.tr,
      'icon': Icons.fact_check_outlined
    },
    {
      'value': 'performance',
      'label': 'report_type_performance'.tr,
      'icon': Icons.bar_chart_outlined
    },
    {
      'value': 'financial',
      'label': 'report_type_financial'.tr,
      'icon': Icons.account_balance_wallet_outlined
    },
  ];

  @override
  void initState() {
    super.initState();
    _autoFillTitle();
  }

  void _autoFillTitle() {
    final now = DateTime.now();
    final label = _types
        .firstWhere((t) => t['value'] == _type)['label'] as String;
    final monthName = AppConstants.getMonthName(now.month);
    _titleController.text = '$label - $monthName ${now.year}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text('report_create_title'.tr,
                  style: AppTextStyles.titleMedium
                      .copyWith(color: scheme.onSurface)),
              const SizedBox(height: 20),
              Text('report_create_type'.tr,
                  style: AppTextStyles.inputLabel),
              const SizedBox(height: 8),
              Row(
                children: _types.map((t) {
                  final selected = _type == t['value'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(
                                () => _type = t['value'] as String);
                        _autoFillTitle();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withOpacity(0.1)
                              : scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: selected ? 1.5 : 1),
                        ),
                        child: Column(
                          children: [
                            Icon(t['icon'] as IconData,
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.grey400,
                                size: 20),
                            const SizedBox(height: 4),
                            Text(
                              (t['label'] as String)
                                  .split(' ')
                                  .first,
                              style: AppTextStyles.labelSmall
                                  .copyWith(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.grey500,
                                  fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text('report_create_name'.tr,
                  style: AppTextStyles.inputLabel),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                validator: (v) => v == null || v.isEmpty
                    ? 'required_field'.tr
                    : null,
                decoration: _inputDeco(
                    context,
                    hint: 'report_create_name_hint'.tr),
                style: AppTextStyles.inputText,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('report_create_from'.tr,
                            style: AppTextStyles.inputLabel),
                        const SizedBox(height: 6),
                        _DateField(
                            hint: 'report_create_start'.tr,
                            value: _start,
                            onPicked: (d) =>
                                setState(() => _start = d)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('report_create_to'.tr,
                            style: AppTextStyles.inputLabel),
                        const SizedBox(height: 6),
                        _DateField(
                            hint: 'report_create_end'.tr,
                            value: _end,
                            onPicked: (d) =>
                                setState(() => _end = d)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Obx(() => ElevatedButton(
                onPressed: widget.controller.isSubmitting.value
                    ? null
                    : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: widget.controller.isSubmitting.value
                    ? const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2)
                    : Text('report_create_button'.tr,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w600)),
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_start == null) {
      Helpers.showWarning('report_create_start_required'.tr);
      return;
    }
    if (_end == null) {
      Helpers.showWarning('report_create_end_required'.tr);
      return;
    }
    widget.controller.createReport(
        type: _type,
        title: _titleController.text.trim(),
        start: _start!,
        end: _end!);
  }

  InputDecoration _inputDeco(BuildContext context, {String? hint}) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.inputHint,
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: AppColors.primary, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error)),
    );
  }
}

class _DateField extends StatelessWidget {
  final String hint;
  final String? value;
  final void Function(String) onPicked;
  const _DateField(
      {required this.hint, required this.onPicked, this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () async {
        final localeCtrl = Get.find<LocaleController>();
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          locale: localeCtrl.currentLocale.value,
        );
        if (picked != null)
          onPicked(picked.toIso8601String().split('T').first);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: value != null
                  ? AppColors.primary
                  : AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(value ?? hint,
                  style: AppTextStyles.bodySmall.copyWith(
                      color: value != null
                          ? scheme.onSurface
                          : AppColors.grey400)),
            ),
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: AppColors.grey400),
          ],
        ),
      ),
    );
  }
}

// ==================== Export Button ====================

class _ExportButton extends StatefulWidget {
  final ReportModel report;
  const _ExportButton({required this.report});

  @override
  State<_ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends State<_ExportButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : _export,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: _loading
              ? AppColors.grey100
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color:
              _loading ? AppColors.grey300 : AppColors.primary,
              width: 1),
        ),
        child: _loading
            ? SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.primary))
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.picture_as_pdf_outlined,
                size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text('report_export_pdf'.tr,
                style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Future<void> _export() async {
    setState(() => _loading = true);
    try {
      await PdfHelper.exportReport(widget.report);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'report_export_failed'.tr
                    .replaceAll('@error', e.toString()),
                style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}