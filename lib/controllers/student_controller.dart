// // lib/controllers/student_controller.dart
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../data/models/student_model.dart';
// import '../data/models/notification_model.dart';
// import '../data/repositories/student_repository.dart';
// import '../utils/constants.dart';
// import '../utils/helpers.dart';
//
// class StudentController extends GetxController {
//   final StudentRepository _repo = StudentRepository();
//
//   // ==================== State ====================
//   final isLoading = false.obs;
//   final isLoadingMore = false.obs;
//   final isSubmitting = false.obs;
//   final students = <StudentModel>[].obs;
//   final selectedStudent = Rxn<StudentModel>();
//   final errorMessage = ''.obs;
//
//   // Pagination
//   final currentPage = 1.obs;
//   final totalPages = 1.obs;
//   final hasMore = false.obs;
//
//   // Search
//   final searchController = TextEditingController();
//   final searchQuery = ''.obs;
//
//   // Filter
//   final selectedSectionId = Rxn<int>();
//
//   // Form
//   final formKey = GlobalKey<FormState>();
//   final firstNameController = TextEditingController();
//   final lastNameController = TextEditingController();
//   final dateOfBirthController = TextEditingController();
//   final addressController = TextEditingController();
//   final selectedGender = 'male'.obs;
//   final selectedParentId = Rxn<int>();
//   final selectedSectionIdForm = Rxn<int>();
//   final selectedAcademicYear = ''.obs;
//
//   // ==================== Init ====================
//   @override
//   void onInit() {
//     super.onInit();
//     loadStudents();
//     debounce(searchQuery, (_) => _onSearch(),
//         time: const Duration(milliseconds: 500));
//   }
//
//   // ==================== Load ====================
//   Future<void> loadStudents({bool reset = true}) async {
//     if (reset) {
//       currentPage.value = 1;
//       students.clear();
//     }
//     isLoading.value = reset;
//     errorMessage.value = '';
//
//     try {
//       final result = await _repo.getAll(
//         page: currentPage.value,
//         limit: AppConstants.defaultPageSize,
//         search: searchQuery.value.isEmpty ? null : searchQuery.value,
//       );
//       if (reset) {
//         students.assignAll(result.data);
//       } else {
//         students.addAll(result.data);
//       }
//       totalPages.value = result.meta.totalPages;
//       hasMore.value = result.meta.hasNextPage;
//     } catch (e) {
//       errorMessage.value =
//           Helpers.parseApiError(e.toString().replaceAll('Exception: ', ''));
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> loadMore() async {
//     if (!hasMore.value || isLoadingMore.value) return;
//     isLoadingMore.value = true;
//     currentPage.value++;
//     try {
//       final result = await _repo.getAll(
//         page: currentPage.value,
//         search: searchQuery.value.isEmpty ? null : searchQuery.value,
//       );
//       students.addAll(result.data);
//       hasMore.value = result.meta.hasNextPage;
//     } catch (_) {
//       currentPage.value--;
//     } finally {
//       isLoadingMore.value = false;
//     }
//   }
//
//   Future<void> loadBySection(int sectionId) async {
//     isLoading.value = true;
//     try {
//       final result = await _repo.getBySection(sectionId);
//       students.assignAll(result);
//     } catch (e) {
//       errorMessage.value =
//           Helpers.parseApiError(e.toString().replaceAll('Exception: ', ''));
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> loadStudentDetails(int id) async {
//     isLoading.value = true;
//     try {
//       final student = await _repo.getById(id);
//       selectedStudent.value = student;
//     } catch (e) {
//       Helpers.showError(
//           Helpers.parseApiError(e.toString().replaceAll('Exception: ', '')));
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // ==================== Create ====================
//   Future<void> createStudent() async {
//     if (!formKey.currentState!.validate()) return;
//     isSubmitting.value = true;
//     try {
//       final dto = CreateStudentDto(
//         firstName: firstNameController.text.trim(),
//         lastName: lastNameController.text.trim(),
//         dateOfBirth: dateOfBirthController.text.trim(),
//         gender: selectedGender.value,
//         address: addressController.text.trim().isEmpty
//             ? null
//             : addressController.text.trim(),
//         parentId: selectedParentId.value,
//         sectionId: selectedSectionIdForm.value,
//         academicYear: selectedAcademicYear.value.isEmpty
//             ? null
//             : selectedAcademicYear.value,
//       );
//       final student = await _repo.create(dto);
//       students.insert(0, student);
//       Helpers.showSuccess('تم تسجيل الطالب بنجاح');
//       clearForm();
//       Get.back();
//     } catch (e) {
//       Helpers.showError(
//           Helpers.parseApiError(e.toString().replaceAll('Exception: ', '')));
//     } finally {
//       isSubmitting.value = false;
//     }
//   }
//
//   // ==================== Update ====================
//   Future<void> updateStudent(int id) async {
//     if (!formKey.currentState!.validate()) return;
//     isSubmitting.value = true;
//     try {
//       final dto = UpdateStudentDto(
//         firstName: firstNameController.text.trim(),
//         lastName: lastNameController.text.trim(),
//         address: addressController.text.trim().isEmpty
//             ? null
//             : addressController.text.trim(),
//         parentId: selectedParentId.value,
//         sectionId: selectedSectionIdForm.value,
//         academicYear: selectedAcademicYear.value.isEmpty
//             ? null
//             : selectedAcademicYear.value,
//       );
//       final updated = await _repo.update(id, dto);
//       final idx = students.indexWhere((s) => s.id == id);
//       if (idx != -1) students[idx] = updated;
//       if (selectedStudent.value?.id == id) selectedStudent.value = updated;
//       Helpers.showSuccess('تم تحديث بيانات الطالب');
//       Get.back();
//     } catch (e) {
//       Helpers.showError(
//           Helpers.parseApiError(e.toString().replaceAll('Exception: ', '')));
//     } finally {
//       isSubmitting.value = false;
//     }
//   }
//
//   // ==================== Delete ====================
//   Future<void> deleteStudent(int id) async {
//     final confirmed = await Helpers.showConfirmDialog(
//       title: 'حذف الطالب',
//       message: 'هل أنت متأكد من حذف هذا الطالب؟ لا يمكن التراجع عن هذا الإجراء.',
//       confirmText: 'حذف',
//       isDanger: true,
//     );
//     if (confirmed != true) return;
//
//     isSubmitting.value = true;
//     try {
//       await _repo.delete(id);
//       students.removeWhere((s) => s.id == id);
//       if (selectedStudent.value?.id == id) selectedStudent.value = null;
//       Helpers.showSuccess('تم حذف الطالب بنجاح');
//       if (Get.currentRoute != '/students') Get.back();
//     } catch (e) {
//       Helpers.showError(
//           Helpers.parseApiError(e.toString().replaceAll('Exception: ', '')));
//     } finally {
//       isSubmitting.value = false;
//     }
//   }
//
//   // ==================== Form Helpers ====================
//   void populateForm(StudentModel student) {
//     firstNameController.text = student.firstName;
//     lastNameController.text = student.lastName;
//     dateOfBirthController.text = (student.dateOfBirth ?? '').split('T').first;
//     addressController.text = student.address ?? '';
//     selectedGender.value = student.gender ?? "male";
//     selectedParentId.value = student.parentId;
//     selectedSectionIdForm.value = student.sectionId;
//     selectedAcademicYear.value = student.academicYear ?? '';
//   }
//
//   void clearForm() {
//     firstNameController.clear();
//     lastNameController.clear();
//     dateOfBirthController.clear();
//     addressController.clear();
//     selectedGender.value = 'male';
//     selectedParentId.value = null;
//     selectedSectionIdForm.value = null;
//     selectedAcademicYear.value = '';
//   }
//
//   void _onSearch() => loadStudents();
//
//   void onSearchChanged(String value) => searchQuery.value = value;
//
//   Future<void> refresh() => loadStudents();
//
//   @override
//   void onClose() {
//     searchController.dispose();
//     firstNameController.dispose();
//     lastNameController.dispose();
//     dateOfBirthController.dispose();
//     addressController.dispose();
//     super.onClose();
//   }
// }