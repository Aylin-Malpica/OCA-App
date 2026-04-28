import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TokenService {
  final String? tokenURL = dotenv.env['TOKEN_URL'];
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
        return _token;
      }
    }

    if (tokenURL == null || tokenURL!.isEmpty) {
      throw Exception("TOKEN_URL no está configurado en el .env");
    }

    final response = await http.post(
      Uri.parse(tokenURL!),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "username": "UsuarioOCA",
        "password": "Contraseñadeprueba",
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      _token = data["data"]["token"];
      _expires = DateTime.parse(data["data"]["expiresUtc"]);

      return _token;
    }

    return null;
  }
}