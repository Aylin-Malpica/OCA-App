import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../core/network/token_service.dart';

class ExternalRegisterRemoteDatasource {
  final TokenService tokenService;
  final String? baseURL = dotenv.env['BASE_URL'];

  ExternalRegisterRemoteDatasource(this.tokenService);

  Future<List<dynamic>> getBusinessUnits() async {
    if (baseURL == null || baseURL!.isEmpty) {
      throw Exception("BASE_URL no está configurado en el .env");
    }

    final token = await tokenService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("No se pudo obtener token");
    }

    final uri = Uri.parse("$baseURL/catalogos/unidades-negocio");

    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["data"] ?? [];
    }

    throw Exception("No se pudieron cargar las unidades de negocio");
  }

  Future<List<dynamic>> getTechnicalLocations({
    required int unidadNegocioId,
  }) async {
    if (baseURL == null || baseURL!.isEmpty) {
      throw Exception("BASE_URL no está configurado en el .env");
    }

    final token = await tokenService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("No se pudo obtener token");
    }

    final uri = Uri.parse("$baseURL/catalogos/ubicaciones-tecnicas").replace(
      queryParameters: {
        "unidadNegocioId": unidadNegocioId.toString(),
        "updatedAfter": "2026-01-01T00:00:00",
      },
    );

    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["data"] ?? [];
    }

    throw Exception("No se pudieron cargar las ubicaciones técnicas");
  }

  Future<List<dynamic>> getDepartments() async {
    if (baseURL == null || baseURL!.isEmpty) {
      throw Exception("BASE_URL no está configurado en el .env");
    }

    final token = await tokenService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("No se pudo obtener token");
    }

    final uri = Uri.parse("$baseURL/catalogos/departamentos");

    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["data"] ?? [];
    }

    throw Exception("No se pudieron cargar los departamentos");
  }

  Future<Map<String, dynamic>> registerExternalUser({
    required String nombreUsuario,
    required String nombres,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String correo,
    required String contrasenia,
    required String confirmarContrasenia,
    required int unidadNegocioId,
    required int departamentoId,
    required int ubicacionTecnicaId,
  }) async {
    if (baseURL == null || baseURL!.isEmpty) {
      throw Exception("BASE_URL no está configurado en el .env");
    }

    final token = await tokenService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("No se pudo obtener token");
    }

    final uri = Uri.parse(
      "$baseURL/auth/usuarios-moviles/registrar-externo",
    );

    final Map<String, dynamic> body = {
      "nombreUsuario": nombreUsuario,
      "nombres": nombres,
      "apellidoPaterno": apellidoPaterno,
      "apellidoMaterno": apellidoMaterno,
      "contrasenia": contrasenia,
      "confirmarContrasenia": confirmarContrasenia,
      "unidadNegocioId": unidadNegocioId,
      "departamentoId": departamentoId,
      "ubicacionTecnicaId": ubicacionTecnicaId,
    };

    if (correo.trim().isNotEmpty) {
      body["correo"] = correo.trim();
    }

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    print("REGISTER EXTERNAL URL: $uri");
    print("REGISTER EXTERNAL STATUS: ${response.statusCode}");
    print("REGISTER EXTERNAL BODY REQUEST: ${jsonEncode(body)}");
    print("REGISTER EXTERNAL BODY RESPONSE: ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }

    throw Exception(
      data["message"] ??
          data["title"] ??
          "No se pudo registrar el usuario externo",
    );
  }
}