import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../core/network/api_client.dart';

class LoginRemoteDatasource {
  final baseURL = dotenv.env['BASE_URL'];
  final ApiClient api;

  LoginRemoteDatasource(this.api);



  Future<Map<String, dynamic>?> verifyEmployee(String employeeId) async {

    final response = await api.post(
      "$baseURL/auth/usuarios-moviles/validar",
      body: {
        "numeroEmpleado": employeeId
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }
}