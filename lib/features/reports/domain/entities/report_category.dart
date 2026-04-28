import 'package:hive/hive.dart';

part 'report_category.g.dart';

@HiveType(typeId: 2)
class ReportCategory {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String descripcion;

  @HiveField(2)
  final String requiereEvidencia;

  ReportCategory({
    required this.id,
    required this.descripcion,
    required this.requiereEvidencia,
  });

  factory ReportCategory.fromJson(Map<String, dynamic> json) {
    return ReportCategory(
      id: json["id"] ?? 0,
      descripcion: json["descripcion"] ?? "",
      requiereEvidencia: json["requiereEvidencia"] ?? "",
    );
  }
}