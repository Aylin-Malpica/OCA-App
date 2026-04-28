import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/network/api_client.dart';

class ReportsRemoteDatasource {
  final ApiClient api;
  final String? baseURL = dotenv.env['BASE_URL'];

  ReportsRemoteDatasource(this.api);

  Future<Map<String, dynamic>?> sendReport(
      Map<String, dynamic> payload,
      ) async {
    final response = await api.post(
      "$baseURL/reporte-resultado",
      body: payload,
    );

    print("SEND REPORT STATUS: ${response.statusCode}");
    print("SEND REPORT BODY: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    return null;
  }

  Future<Map<String, dynamic>?> sendEvidences({
    required int resultadoReporteId,
    required List<String> evidenciasBase64,
  }) async {
    final payload = {
      "evidencias": evidenciasBase64.map((img) {
        return {
          "base64": img,
        };
      }).toList(),
    };

    print("========== ENVIANDO EVIDENCIAS ==========");
    print("RESULTADO REPORTE ID: $resultadoReporteId");
    print("TOTAL FOTOS: ${evidenciasBase64.length}");

    final response = await api.post(
      "$baseURL/reporte-resultado/$resultadoReporteId/evidencias",
      body: payload,
    );

    print("SEND EVIDENCES STATUS: ${response.statusCode}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    return null;
  }
}