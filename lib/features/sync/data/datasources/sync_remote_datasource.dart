import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../core/network/api_client.dart';
import '../../../reports/data/datasources/local_reports_local_datasource.dart';
import '../../../reports/domain/entities/local_report.dart';

class SyncRemoteDatasource {
  final ApiClient api;

  final LocalReportsLocalDatasource reportsLocalDatasource =
  LocalReportsLocalDatasource();

  final String? baseURL = dotenv.env['BASE_URL'];

  SyncRemoteDatasource(this.api);

  Future<List<dynamic>> syncCatalog({
    required String endpoint,
    required int unidadNegocioId,
    required String fechaActualizacion,
    String dateParamName = "updatedAfter",
  }) async {
    final uri = Uri.parse("$baseURL/$endpoint").replace(
      queryParameters: {
        "unidadNegocioId": unidadNegocioId.toString(),
        dateParamName: fechaActualizacion,
      },
    );

    final response = await api.get(uri.toString());

    print("SYNC URL: $uri");
    print("SYNC ENDPOINT: $endpoint");
    print("SYNC STATUS: ${response.statusCode}");
    print("SYNC BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["data"] ?? [];
    }

    return [];
  }

  Future<int> syncReportsByUser({
    required int usuarioMovilId,
    required String numeroEmpleado,
  }) async {
    final uri = Uri.parse(
      "$baseURL/reporte-resultado/usuario/$usuarioMovilId",
    );

    final response = await api.get(uri.toString());

    print("SYNC REPORTS URL: $uri");
    print("SYNC REPORTS STATUS: ${response.statusCode}");
    print("SYNC REPORTS BODY: ${response.body}");

    if (response.statusCode != 200) {
      return 0;
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      print("SYNC REPORTS ERROR: respuesta inválida");
      return 0;
    }

    if (decoded["success"] != true) {
      print(
        "SYNC REPORTS ERROR: "
            "${decoded["message"] ?? "respuesta sin éxito"}",
      );
      return 0;
    }

    final data = decoded["data"];

    if (data is! List) {
      print("SYNC REPORTS ERROR: data no es una lista");
      return 0;
    }

    int savedReports = 0;

    for (final item in data) {
      try {
        if (item is! Map) {
          continue;
        }

        final reportJson = Map<String, dynamic>.from(item);

        final localReport = LocalReport.fromRemoteJson(
          reportJson,
          numeroEmpleado: numeroEmpleado,
        );

        await reportsLocalDatasource.upsertRemoteReport(
          localReport,
        );

        savedReports++;
      } catch (e, stackTrace) {
        print("ERROR GUARDANDO REPORTE REMOTO: $e");
        print(stackTrace);
      }
    }

    print(
      "SYNC REPORTS COMPLETADA: "
          "$savedReports de ${data.length} reporte(s)",
    );

    return savedReports;
  }
}