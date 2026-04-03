// lib/data/models/report_model.dart

class ReportModel {
  final int id;
  final int generatedBy;
  final String type;
  final String title;
  final Map<String, dynamic> parameters;
  final Map<String, dynamic> data;
  final String format;
  final String? filePath;
  final String? periodStart;
  final String? periodEnd;
  final String? generatedAt;
  final String? createdAt;
  final ReportGenerator? generator;

  const ReportModel({
    required this.id,
    required this.generatedBy,
    required this.type,
    required this.title,
    required this.parameters,
    required this.data,
    required this.format,
    this.filePath,
    this.periodStart,
    this.periodEnd,
    this.generatedAt,
    this.createdAt,
    this.generator,
  });

  String get typeLabel {
    switch (type) {
      case 'attendance': return 'حضور وغياب';
      case 'performance': return 'أداء أكاديمي';
      case 'financial': return 'مالي';
      default: return type;
    }
  }

  String get typeIcon {
    switch (type) {
      case 'attendance': return 'fact_check';
      case 'performance': return 'bar_chart';
      case 'financial': return 'attach_money';
      default: return 'description';
    }
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as int,
      generatedBy: json['generatedBy'] as int? ?? 0,
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      parameters: json['parameters'] as Map<String, dynamic>? ?? {},
      data: json['data'] as Map<String, dynamic>? ?? {},
      format: json['format'] as String? ?? 'json',
      filePath: json['filePath'] as String?,
      periodStart: json['periodStart'] as String?,
      periodEnd: json['periodEnd'] as String?,
      generatedAt: json['generatedAt'] as String?,
      createdAt: json['createdAt'] as String?,
      generator: json['generator'] != null
          ? ReportGenerator.fromJson(json['generator'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ReportGenerator {
  final int id;
  final String email;

  const ReportGenerator({required this.id, required this.email});

  factory ReportGenerator.fromJson(Map<String, dynamic> json) {
    return ReportGenerator(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
    );
  }
}

class CreateReportDto {
  final String type;
  final String title;
  final String periodStart;
  final String periodEnd;

  const CreateReportDto({
    required this.type,
    required this.title,
    required this.periodStart,
    required this.periodEnd,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'title': title,
    'periodStart': periodStart,
    'periodEnd': periodEnd,
  };
}