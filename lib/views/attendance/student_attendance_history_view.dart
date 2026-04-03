import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/attendance_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/loading_widget.dart';

class StudentAttendanceHistoryView
    extends GetView<AttendanceController> {
  const StudentAttendanceHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map?;
    final studentId = args?['studentId'] as int?;
    final studentName =
        args?['studentName'] as String? ?? 'student'.tr;

    if (studentId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadStudentHistory(studentId);
        controller.loadStudentStats(studentId);
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('history_title'.tr,
                style: AppTextStyles.titleSmall
                    .copyWith(color: Colors.white)),
            Text(studentName,
                style: AppTextStyles.bodySmall
                    .copyWith(color: Colors.white70)),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return LoadingWidget(message: 'history_loading'.tr);
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildStats(context),
            ),
            controller.studentHistory.isEmpty
                ? SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: EmptyWidget(
                  title: 'history_empty'.tr,
                  icon: Icons.event_busy_outlined,
                ),
              ),
            )
                : SliverList(
              delegate: SliverChildBuilderDelegate(
                    (_, i) => _HistoryTile(
                    record:
                    controller.studentHistory[i]),
                childCount:
                controller.studentHistory.length,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStats(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final stats = controller.studentStats.value;
    if (stats == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('history_stats'.tr,
              style: AppTextStyles.titleSmall
                  .copyWith(color: AppColors.primary)),
          const SizedBox(height: 12),
          Row(
            children: [
              _statBox('${stats.present}',
                  'status_present'.tr, AppColors.success),
              _statBox('${stats.absent}',
                  'status_absent'.tr, AppColors.error),
              _statBox('${stats.late}', 'status_late'.tr,
                  AppColors.warning),
              _statBox('${stats.excused}',
                  'status_excused'.tr, AppColors.info),
            ],
          ),
          const SizedBox(height: 14),
          PercentageBar(
            value: stats.attendanceRate / 100,
            color: AppColors.getAttendanceColor(
              stats.attendanceRate >= 80
                  ? 'present'
                  : stats.attendanceRate >= 60
                  ? 'late'
                  : 'absent',
            ),
            height: 10,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('history_rate'.tr,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.grey500)),
              Text(
                Helpers.formatPercentage(
                    stats.attendanceRate),
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.getAttendanceColor(
                    stats.attendanceRate >= 80
                        ? 'present'
                        : 'absent',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(String count, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(count,
              style: AppTextStyles.headlineSmall
                  .copyWith(color: color)),
          Text(label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: color, fontSize: 10)),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final record;
  const _HistoryTile({required this.record});

  Color _statusColor(String status) {
    switch (status) {
      case 'present': return AppColors.success;
      case 'absent': return AppColors.error;
      case 'late': return AppColors.warning;
      case 'excused': return AppColors.info;
      default: return AppColors.grey400;
    }
  }

  String _statusLabel(String status) =>
      'status_$status'.tr;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _statusColor(record.status);

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          right: BorderSide(color: color, width: 4),
        ),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Helpers.formatDate(record.date),
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                if (record.lateMinutes != null &&
                    record.lateMinutes > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                      'history_late_minutes'.tr.replaceAll(
                          '@min', '${record.lateMinutes}'),
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.warning)),
                ],
                if (record.notes != null) ...[
                  const SizedBox(height: 2),
                  Text(record.notes!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.grey500)),
                ],
              ],
            ),
          ),
          StatusBadge(
              label: _statusLabel(record.status),
              color: color),
        ],
      ),
    );
  }
}