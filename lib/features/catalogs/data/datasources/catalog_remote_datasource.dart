import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/network/api_client.dart';

class CatalogRemoteDatasource {
  final ApiClient api;
  final String? baseURL = dotenv.env['BASE_URL'];

  CatalogRemoteDatasource(this.api);

  Future<List<dynamic>> getUnidadesNegocio() async {
    final response = await api.get(
      "$baseURL/catalogos/unidades-negocio",
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["data"] ?? [];
    }

    return [];
  }
}