import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../core/network/api_client.dart';

class LoginRemoteDatasource {
  final baseURL = dotenv.env['BASE_URL'];
  final ApiClient api;

  LoginRemoteDatasource(this.api);



  Future<Map<String, dynamic>?> verifyEmployee(String employeeId) async {
    print("ete es el empleado" '$employeeId');
    final response = await api.post(
      "$baseURL/auth/usuarios-moviles/validar",
      body: {
        "numeroEmpleado": employeeId
      },
    );
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      print("todo ok");
      return jsonDecode(response.body);
    }

    return null;
  }
}