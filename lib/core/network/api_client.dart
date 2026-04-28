import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class ApiClient {
  final TokenService tokenService = TokenService();

  Future<http.Response> post(String url, {Map<String, dynamic>? body}) async {
    final token = await tokenService.getToken();

    return http.post(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> get(String url) async {
    final token = await tokenService.getToken();

    return http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
  }
}