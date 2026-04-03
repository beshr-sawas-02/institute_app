import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/attendance_controller.dart';
import '../../controllers/section_controller.dart';
import '../../controllers/locale_controller.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/grade_model.dart';
import '../../data/models/section_model.dart';
import '../../data/models/student_model.dart';
import '../../data/repositories/student_repository.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/helpers.dart';
import '../../widgets/empty_widget.dart';

class SingleAttendanceView extends StatefulWidget {
  const SingleAttendanceView({super.key});

  @override
  State<SingleAttendanceView> createState() => _SingleAttendanceViewState();
}

class _SingleAttendanceViewState extends State<SingleAttendanceView> {
  final _studentRepo = StudentRepository();
  final _attendanceCtrl = Get.find<AttendanceController>();
  final _sectionCtrl = Get.find<SectionController>();

  GradeModel? _selectedGrade;
  SectionModel? _selectedSection;
  List<StudentModel> _students = [];
  bool _loadingStudents = false;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onGradeSelected(GradeModel grade) {
    setState(() {
      _selectedGrade = grade;
      _selectedSection = null;
      _students = [];
      _searchQuery = '';
      _searchCtrl.clear();
    });
  }

  Future<void> _onSectionSelected(SectionModel section) async {
    setState(() {
      _selectedSection = section;
      _students = [];
      _searchQuery = '';
      _searchCtrl.clear();
      _loadingStudents = true;
    });
    try {
      final students = await _studentRepo.getBySection(section.id);
      setState(() => _students = students);
    } catch (e) {
      Helpers.showError(
          Helpers.parseApiError(e.toString().replaceAll('Exception: ', '')));
    } finally {
      setState(() => _loadingStudents = false);
    }
  }

  List<SectionModel> get _sectionsForGrade {
    if (_selectedGrade == null) return [];
    return _sectionCtrl.sectionsByGrade(_selectedGrade!.id);
  }

  List<StudentModel> get _filteredStudents {
    if (_searchQuery.isEmpty) return _students;
    return _students.where((s) {
      final name = '${s.firstName} ${s.lastName}'.toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _showAttendanceSheet(StudentModel student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AttendanceBottomSheet(
        student: student,
        date: _attendanceCtrl.selectedDate.value,
        onSaved: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text('attendance_single_title'.tr,
            style:
            AppTextStyles.titleMedium.copyWith(color: Colors.white)),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: _DateBar(ctrl: _attendanceCtrl),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGradePicker(),
          if (_selectedGrade != null) _buildSectionPicker(),
          if (_students.isNotEmpty)
            _SearchBar(
              ctrl: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          Expanded(child: _buildStudentList()),
        ],
      ),
    );
  }

  Widget _buildGradePicker() {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      color: scheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text('attendance_select_grade'.tr,
                  style: AppTextStyles.labelMedium.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (_sectionCtrl.grades.isEmpty) {
              return Center(
                child: SizedBox(
                  height: 32,
                  child: CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 2),
                ),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sectionCtrl.grades.map((g) {
                final isSelected = _selectedGrade?.id == g.id;
                return GestureDetector(
                  onTap: () => _onGradeSelected(g),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      g.name,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isSelected ? Colors.white : AppColors.primary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionPicker() {
    final scheme = Theme.of(context).colorScheme;
    final sections = _sectionsForGrade;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                    color: AppColors.info, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text('attendance_select_section'.tr,
                  style: AppTextStyles.labelMedium.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Text('(${_selectedGrade!.name})',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.grey500)),
            ],
          ),
          const SizedBox(height: 10),
          if (sections.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('attendance_no_sections_for_grade'.tr,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.grey400)),
            )
          else
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: sections.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final s = sections[i];
                  final isSelected = _selectedSection?.id == s.id;
                  return GestureDetector(
                    onTap: () => _onSectionSelected(s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.info
                            : AppColors.info.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.info
                              : AppColors.info.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        '${'section'.tr} ${s.name}',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isSelected ? Colors.white : AppColors.info,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    if (_selectedGrade == null) {
      return EmptyWidget(
        title: 'attendance_select_grade_first'.tr,
        subtitle: 'attendance_select_grade_first_sub'.tr,
        icon: Icons.school_outlined,
      );
    }
    if (_selectedSection == null) {
      return EmptyWidget(
        title: 'attendance_select_section'.tr,
        subtitle: 'attendance_select_section_sub'.tr,
        icon: Icons.class_outlined,
      );
    }
    if (_loadingStudents) {
      return Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_students.isEmpty) {
      return EmptyWidget(
        title: 'attendance_no_students_found'.tr,
        icon: Icons.person_off_outlined,
      );
    }
    final list = _filteredStudents;
    if (list.isEmpty) {
      return EmptyWidget(
        title: 'no_results'.tr,
        icon: Icons.search_off_rounded,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (_, i) => _StudentTile(
        student: list[i],
        onTap: () => _showAttendanceSheet(list[i]),
      ),
    );
  }
}

class _DateBar extends StatelessWidget {
  final AttendanceController ctrl;
  const _DateBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined,
              color: Colors.white70, size: 15),
          const SizedBox(width: 6),
          Obx(() => Text(
            Helpers.formatDate(
                ctrl.selectedDate.value.toIso8601String()),
            style:
            AppTextStyles.bodySmall.copyWith(color: Colors.white),
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
              const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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

class _SearchBar extends StatelessWidget {
  final TextEditingController ctrl;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.ctrl, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: TextField(
        controller: ctrl,
        onChanged: onChanged,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'attendance_search_student'.tr,
          hintStyle:
          AppTextStyles.bodySmall.copyWith(color: AppColors.grey400),
          prefixIcon: Icon(Icons.search_rounded,
              color: AppColors.grey400, size: 20),
          suffixIcon: ctrl.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.close,
                size: 18, color: AppColors.grey400),
            onPressed: () {
              ctrl.clear();
              onChanged('');
            },
          )
              : null,
          filled: true,
          fillColor: scheme.surface,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final StudentModel student;
  final VoidCallback onTap;
  const _StudentTile({required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
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
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  student.firstName.isNotEmpty
                      ? student.firstName[0]
                      : '؟',
                  style: AppTextStyles.titleSmall
                      .copyWith(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${student.firstName} ${student.lastName}',
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600)),
                  if (student.section != null)
                    Text(student.section!.name,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.grey500)),
                ],
              ),
            ),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('attendance_register'.tr,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceBottomSheet extends StatefulWidget {
  final StudentModel student;
  final DateTime date;
  final VoidCallback onSaved;

  const _AttendanceBottomSheet({
    required this.student,
    required this.date,
    required this.onSaved,
  });

  @override
  State<_AttendanceBottomSheet> createState() =>
      _AttendanceBottomSheetState();
}

class _AttendanceBottomSheetState extends State<_AttendanceBottomSheet> {
  final _ctrl = Get.find<AttendanceController>();
  String _status = 'present';
  int _lateMinutes = 0;
  final _notesCtrl = TextEditingController();
  final _lateCtrl = TextEditingController(text: '0');

  List<Map<String, dynamic>> get _statuses => [
    {'key': 'present', 'label': 'status_present'.tr, 'icon': Icons.check_circle_rounded},
    {'key': 'absent', 'label': 'status_absent'.tr, 'icon': Icons.cancel_rounded},
    {'key': 'late', 'label': 'status_late'.tr, 'icon': Icons.watch_later_rounded},
    {'key': 'excused', 'label': 'status_excused'.tr, 'icon': Icons.assignment_late_rounded},
  ];

  @override
  void dispose() {
    _notesCtrl.dispose();
    _lateCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final dto = CreateAttendanceDto(
      studentId: widget.student.id,
      date: Helpers.toApiDate(widget.date),
      status: _status,
      lateMinutes: _status == 'late' ? _lateMinutes : null,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    await _ctrl.createSingle(dto);
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 8,
      ),
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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.student.firstName.isNotEmpty
                        ? widget.student.firstName[0]
                        : '؟',
                    style: AppTextStyles.titleMedium
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '${widget.student.firstName} ${widget.student.lastName}',
                        style: AppTextStyles.titleSmall),
                    Text(
                        Helpers.formatDate(
                            widget.date.toIso8601String()),
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.grey500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text('attendance_status'.tr,
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.grey500)),
          const SizedBox(height: 10),
          Row(
            children: _statuses.map((s) {
              final key = s['key'] as String;
              final isSelected = _status == key;
              final color = AppColors.getAttendanceColor(key);
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _status = key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.12)
                          : scheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : AppColors.grey200,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(s['icon'] as IconData,
                            size: 22,
                            color: isSelected ? color : AppColors.grey400),
                        const SizedBox(height: 4),
                        Text(s['label'] as String,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isSelected ? color : AppColors.grey500,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            )),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          if (_status == 'late') ...[
            Text('attendance_late_minutes_label'.tr,
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.grey500)),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (_lateMinutes >= 5) {
                      setState(() {
                        _lateMinutes -= 5;
                        _lateCtrl.text = _lateMinutes.toString();
                      });
                    }
                  },
                  icon: Icon(Icons.remove_circle_outline,
                      color: AppColors.primary),
                ),
                Expanded(
                  child: TextField(
                    controller: _lateCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (v) =>
                    _lateMinutes = int.tryParse(v) ?? 0,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: scheme.surface,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      suffixText: 'attendance_minute'.tr,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _lateMinutes += 5;
                      _lateCtrl.text = _lateMinutes.toString();
                    });
                  },
                  icon: Icon(Icons.add_circle_outline,
                      color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          Text('attendance_notes'.tr,
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.grey500)),
          const SizedBox(height: 8),
          TextField(
            controller: _notesCtrl,
            maxLines: 2,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'attendance_notes_hint'.tr,
              hintStyle: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.grey400),
              filled: true,
              fillColor: scheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          Obx(() => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
              _ctrl.isSubmitting.value ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _ctrl.isSubmitting.value
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
                  : Text('attendance_submit'.tr,
                  style: AppTextStyles.titleSmall
                      .copyWith(color: Colors.white)),
            ),
          )),
        ],
      ),
    );
  }
}