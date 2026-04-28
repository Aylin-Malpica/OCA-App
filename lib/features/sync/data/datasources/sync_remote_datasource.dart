import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/network/api_client.dart';

class SyncRemoteDatasource {
  final ApiClient api;
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

}