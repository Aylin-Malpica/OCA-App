import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ExternalAuthDatasource {
  final String? baseUrl = dotenv.env['BASE_URL'];

  String? _token;
  DateTime? _expiresUtc;

  String? get token => _token;

  bool get hasValidToken {
    if (_token == null || _expiresUtc == null) return false;

    final nowUtc = DateTime.now().toUtc();

    return nowUtc.isBefore(_expiresUtc!);
  }

  Future<String> getToken() async {
    if (hasValidToken) {
      return _token!;
    }

    final uri = Uri.parse("$baseUrl/UsuarioAPI");

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
    );

    print("EXTERNAL TOKEN STATUS: ${response.statusCode}");

    if (response.statusCode != 200) {
      throw Exception("No se pudo obtener token externo");
    }

    final data = jsonDecode(response.body);

    final token = data["data"]?["token"];
    final expiresUtcRaw = data["data"]?["expiresUtc"];

    if (token == null || expiresUtcRaw == null) {
      throw Exception("Respuesta de token externo inválida");
    }

    _token = token;
    _expiresUtc = DateTime.parse(expiresUtcRaw).toUtc();

    return _token!;
  }
}