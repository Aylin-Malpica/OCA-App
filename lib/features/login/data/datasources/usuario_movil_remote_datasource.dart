import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../core/network/api_client.dart';

class UsuarioMovilRemoteDatasource {
  final ApiClient apiClient;
  final baseURL = dotenv.env['BASE_URL'];

  UsuarioMovilRemoteDatasource(this.apiClient);


  Future<Map<String, dynamic>> updateContacto({
    required int usuarioMovilId,
    required String correo,
    String? telefono,
  }) async {
    final url = "$baseURL/auth/usuarios-moviles/contacto/$usuarioMovilId";

    final response = await apiClient.patch(
      url,
      body: {
        "correo": correo,
        "telefono": telefono,
      },
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data["message"]?.toString() ?? "Error al actualizar datos de contacto");
    }

    return data;
  }
}