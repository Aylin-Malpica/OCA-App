import '../datasources/local_reports_local_datasource.dart';
import '../datasources/reports_remote_datasource.dart';
import '../../domain/entities/local_report.dart';

class ReportsRepository {
  final ReportsRemoteDatasource remote;
  final LocalReportsLocalDatasource local;

  ReportsRepository({
    required this.remote,
    required this.local,
  });

  Future<Map<String, dynamic>?> sendReport(
      Map<String, dynamic> payload,
      ) async {
    return await remote.sendReport(payload);
  }

  Future<void> saveLocalReport(LocalReport report) async {
    await local.saveReport(report);
  }
}