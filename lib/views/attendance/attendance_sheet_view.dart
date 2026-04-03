import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/attendance_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_widget.dart';

class AttendanceSheetView extends GetView<AttendanceController> {
  const AttendanceSheetView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map?;
    final section = args?['section'];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(section?.name ?? 'attendance_title'.tr,
                style: AppTextStyles.titleSmall
                    .copyWith(color: Colors.white)),
            Obx(() => Text(
              Helpers.formatDate(
                  controller.selectedDate.value.toIso8601String()),
              style: AppTextStyles.bodySmall
                  .copyWith(color: Colors.white60),
            )),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: controller.markAll,
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: 'present',
                  child: Text('attendance_mark_all_present'.tr)),
              PopupMenuItem(
                  value: 'absent',
                  child: Text('attendance_mark_all_absent'.tr)),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return LoadingWidget(message: 'attendance_loading'.tr);
        }
        final sheet = controller.attendanceSheet.value;
        if (sheet == null || sheet.students.isEmpty) {
          return EmptyWidget(
            title: 'attendance_no_students'.tr,
            icon: Icons.people_outline,
          );
        }
        return Column(
          children: [
            _SummaryBar(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: sheet.students.length,
                itemBuilder: (_, i) =>
                    _AttendanceRow(entry: sheet.students[i]),
              ),
            ),
            _SubmitBar(),
          ],
        );
      }),
    );
  }
}

class _SummaryBar extends GetView<AttendanceController> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final s = controller.currentSummary;
      return Container(
        color: scheme.surface,
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _chip(s['present'] ?? 0, 'status_present'.tr, AppColors.success),
            _chip(s['absent'] ?? 0, 'status_absent'.tr, AppColors.error),
            _chip(s['late'] ?? 0, 'status_late'.tr, AppColors.warning),
            _chip(s['excused'] ?? 0, 'status_excused'.tr, AppColors.info),
          ],
        ),
      );
    });
  }

  Widget _chip(int count, String label, Color color) {
    return Column(
      children: [
        Text('$count',
            style: AppTextStyles.titleSmall.copyWith(color: color)),
        Text(label,
            style: AppTextStyles.labelSmall
                .copyWith(color: color, fontSize: 10)),
      ],
    );
  }
}

class _AttendanceRow extends GetView<AttendanceController> {
  final entry;
  const _AttendanceRow({required this.entry});

  List<Map<String, dynamic>> get _statuses => [
    {'value': 'present', 'label': 'status_present'.tr, 'icon': Icons.check_circle},
    {'value': 'absent', 'label': 'status_absent'.tr, 'icon': Icons.cancel},
    {'value': 'late', 'label': 'status_late'.tr, 'icon': Icons.access_time},
    {'value': 'excused', 'label': 'status_excused'.tr, 'icon': Icons.verified},
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'present': return AppColors.success;
      case 'absent': return AppColors.error;
      case 'late': return AppColors.warning;
      case 'excused': return AppColors.info;
      default: return AppColors.grey400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final status = controller.getStudentStatus(entry.studentId);
      final color = _statusColor(status);

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: status != 'present'
                  ? color.withOpacity(0.3)
                  : Colors.transparent),
          boxShadow: [
            BoxShadow(
                color: AppColors.shadow,
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${entry.order}',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.grey500)),
                ),
                const SizedBox(width: 10),
                InitialsAvatar(name: entry.name, size: 36, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(entry.name,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
                StatusBadge(
                    label: _statuses.firstWhere(
                            (s) => s['value'] == status)['label'] as String,
                    color: color),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: _statuses.map((s) {
                final val = s['value'] as String;
                final isSelected = status == val;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => controller.setStudentStatus(
                        entry.studentId, val),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _statusColor(val).withOpacity(0.15)
                            : scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? _statusColor(val)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        s['label'] as String,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 10,
                          color: isSelected
                              ? _statusColor(val)
                              : AppColors.grey500,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (status == 'late') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 16, color: AppColors.warning),
                  const SizedBox(width: 6),
                  Text('attendance_late_minutes'.tr,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.grey600)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 64,
                    height: 32,
                    child: TextFormField(
                      initialValue: controller
                          .getStudentLateMinutes(entry.studentId)
                          .toString(),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: (v) => controller.updateLateMinutes(
                          entry.studentId, int.tryParse(v) ?? 0),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: AppColors.warning, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: AppColors.warning, width: 1.5),
                        ),
                      ),
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _SubmitBar extends GetView<AttendanceController> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      color: scheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Obx(() => CustomButton(
        label: 'attendance_submit'.tr,
        icon: Icons.save_rounded,
        isLoading: controller.isSubmitting.value,
        onPressed: controller.submitSmartBulk,
      )),
    );
  }
}