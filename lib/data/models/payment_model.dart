// lib/data/models/payment_model.dart

import '../../utils/app_colors.dart';
import 'student_model.dart';

class PaymentModel {
  final int id;
  final int studentId;
  final String academicYear;
  final double amount;
  final double discount;
  final double? finalAmount;
  final String status;
  final String dueDate;
  final String? paymentDate;
  final String? receiptNumber;
  final String? notes;
  final String? createdAt;

  // Relations
  final StudentModel? student;

  const PaymentModel({
    required this.id,
    required this.studentId,
    required this.academicYear,
    required this.amount,
    required this.discount,
    this.finalAmount,
    required this.status,
    required this.dueDate,
    this.paymentDate,
    this.receiptNumber,
    this.notes,
    this.createdAt,
    this.student,
  });

  String get statusLabel {
    switch (status) {
      case 'paid': return 'مدفوع';
      case 'pending': return 'معلق';
      case 'partial': return 'جزئي';
      default: return status;
    }
  }

  dynamic get statusColor => AppColors.getPaymentColor(status);

  double get effectiveAmount => finalAmount ?? (amount - discount);

  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending';
  bool get isOverdue {
    if (isPaid) return false;
    try {
      final due = DateTime.parse(dueDate);
      return DateTime.now().isAfter(due);
    } catch (_) {
      return false;
    }
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as int,
      studentId: json['studentId'] as int,
      academicYear: json['academicYear'] as String? ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      discount: double.tryParse(json['discount'].toString()) ?? 0,
      finalAmount: json['finalAmount'] != null
          ? double.tryParse(json['finalAmount'].toString())
          : null,
      status: json['status'] as String? ?? 'pending',
      dueDate: json['dueDate'] as String? ?? '',
      paymentDate: json['paymentDate'] as String?,
      receiptNumber: json['receiptNumber'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as String?,
      student: json['student'] != null
          ? StudentModel.fromJson(json['student'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'academicYear': academicYear,
    'amount': amount,
    'discount': discount,
    'status': status,
    'dueDate': dueDate,
    if (paymentDate != null) 'paymentDate': paymentDate,
    if (notes != null) 'notes': notes,
  };

  @override
  String toString() =>
      'PaymentModel(id: $id, studentId: $studentId, status: $status)';
}

// ==================== Payment Stats ====================

class PaymentStats {
  final double totalPaid;
  final double totalPending;
  final double totalPartial;

  const PaymentStats({
    required this.totalPaid,
    required this.totalPending,
    required this.totalPartial,
  });

  double get totalCollected => totalPaid;
  double get totalOutstanding => totalPending + totalPartial;

  factory PaymentStats.fromJson(Map<String, dynamic> json) {
    return PaymentStats(
      totalPaid: double.tryParse(json['totalPaid'].toString()) ?? 0,
      totalPending: double.tryParse(json['totalPending'].toString()) ?? 0,
      totalPartial: double.tryParse(json['totalPartial'].toString()) ?? 0,
    );
  }
}

// ==================== DTOs ====================

class CreatePaymentDto {
  final int studentId;
  final String academicYear;
  final double amount;
  final double? discount;
  final String? status;
  final String dueDate;
  final String? paymentDate;
  final String? notes;

  const CreatePaymentDto({
    required this.studentId,
    required this.academicYear,
    required this.amount,
    this.discount,
    this.status,
    required this.dueDate,
    this.paymentDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'academicYear': academicYear,
    'amount': amount,
    if (discount != null) 'discount': discount,
    if (status != null) 'status': status,
    'dueDate': dueDate,
    if (paymentDate != null) 'paymentDate': paymentDate,
    if (notes != null) 'notes': notes,
  };
}

class UpdatePaymentDto {
  final double? amount;
  final double? discount;
  final String? status;
  final String? dueDate;
  final String? paymentDate;
  final String? notes;

  const UpdatePaymentDto({
    this.amount,
    this.discount,
    this.status,
    this.dueDate,
    this.paymentDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    if (amount != null) 'amount': amount,
    if (discount != null) 'discount': discount,
    if (status != null) 'status': status,
    if (dueDate != null) 'dueDate': dueDate,
    if (paymentDate != null) 'paymentDate': paymentDate,
    if (notes != null) 'notes': notes,
  };
}