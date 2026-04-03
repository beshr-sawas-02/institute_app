import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/attendance_controller.dart';
import '../../controllers/section_controller.dart';
import '../../controllers/locale_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/helpers.dart';
import '../../widgets/empty_widget.dart';

class AttendanceView extends StatelessWidget {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AttendanceController>()) {
      Get.lazyPut(() => AttendanceController());
    }
    if (!Get.isRegistered<SectionController>()) {
      Get.lazyPut(() => SectionController());
    }
    final sections = Get.find<SectionController>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text('attendance_title'.tr,
            style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DateSelector(),

          // زر الحضور الفردي
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.singleAttendance),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.82),
                    ],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.person_add_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('attendance_single_button'.tr,
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                          Text('attendance_single_desc'.tr,
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: Colors.white70)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white60, size: 16),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text('attendance_bulk_title'.tr,
                style: AppTextStyles.titleSmall
                    .copyWith(color: scheme.onSurface)),
          ),

          Expanded(
            child: Obx(() {
              if (sections.isLoading.value) {
                return Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary));
              }
              if (sections.sections.isEmpty) {
                return EmptyWidget(
                    title: 'attendance_no_sections'.tr,
                    icon: Icons.class_outlined);
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: sections.sections.length,
                itemBuilder: (_, i) =>
                    _SectionCard(section: sections.sections[i]),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AttendanceController>();
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined,
              color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Obx(() => Text(
            Helpers.formatDate(
                ctrl.selectedDate.value.toIso8601String()),
            style:
            AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          )),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              final localeCtrl = Get.find<LocaleController>();
              final picked = await showDatePicker(
                context: context,
                initialDate: ctrl.selectedDate.value,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                locale: localeCtrl.currentLocale.value,
              );
              if (picked != null) ctrl.setDate(picked);
            },
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('change'.tr,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final section;
  const _SectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        Get.find<AttendanceController>().setSection(section);
        Get.toNamed(AppRoutes.attendanceSheet,
            arguments: {'section': section});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
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
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.class_rounded,
                  color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(section.name,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600)),
                  if (section.grade != null)
                    Text(section.grade!.name,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.grey500)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                    'attendance_student_count'.tr.replaceAll(
                        '@count', '${section.studentCount ?? 0}'),
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.grey500)),
                const SizedBox(height: 4),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.grey400),
              ],
            ),
          ],
        ),
      ),
    );
  }
}