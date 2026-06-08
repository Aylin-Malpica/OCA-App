import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TokenService {
  static final TokenService _instance = TokenService._internal();

  factory TokenService() {
    return _instance;
  }

  TokenService._internal();

  String? _token;
  DateTime? _expires;

  Future<String?> getToken() async {
    if (_token != null && _expires != null) {
      if (DateTime.now().isBefore(_expires!)) {
        print("TOKEN CACHE: usando token existente");
        return _token;
      }
    }

    final tokenURL = dotenv.env['TOKEN_URL'];

    if (tokenURL == null || tokenURL.isEmpty) {
      print("TOKEN ERROR: TOKEN_URL no está configurado en .env");
      throw Exception("TOKEN_URL no está configurado en el .env");
    }

    final body = {
      "username": "UsuarioOCA",
      "password": "Contraseñadeprueba",
    };

    print("TOKEN URL: $tokenURL");
    print("TOKEN BODY REQUEST: ${jsonEncode(body)}");

    final response = await http.post(
      Uri.parse(tokenURL),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(body),
    );

    print("TOKEN STATUS: ${response.statusCode}");
    print("TOKEN RESPONSE BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final token = data["data"]?["token"];
      final expiresUtc = data["data"]?["expiresUtc"];

      if (token == null || expiresUtc == null) {
        throw Exception(
          "La respuesta del token no contiene data.token o data.expiresUtc",
        );
      }

      _token = token;
      _expires = DateTime.parse(expiresUtc);

      print("TOKEN OK");
      print("TOKEN EXPIRES: $_expires");

      return _token;
    }

    throw Exception(
      "Error al obtener token. Status: ${response.statusCode}, Body: ${response.body}",
    );
  }
}