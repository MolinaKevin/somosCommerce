import 'dart:convert';
import 'package:http/http.dart' as http;

class CommerceService {
  static const String baseUrl = 'http://localhost/api'; // Cambia a tu URL de API real

  Future<Map<String, dynamic>> fetchCommerces(String token) async {
    final url = Uri.parse('$baseUrl/user/commerces');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    // Agregar impresiones de depuración
    print('Código de estado: ${response.statusCode}');
    print('Respuesta del servidor: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      print('Error al obtener comercios: ${response.statusCode} - ${response.body}');
      return {};
    }
  }


  Future<Map<String, dynamic>?> createCommerce(String token, Map<String, dynamic> commerceData) async {
    final url = Uri.parse('$baseUrl/commerces');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(commerceData),
    );

    if (response.statusCode == 201) { // 201 Created
      return jsonDecode(response.body);
    } else {
      print('Error al crear comercio: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  Future<bool> activateCommerce(String token, int commerceId) async {
    final url = Uri.parse('$baseUrl/user/commerces/$commerceId/activate');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) { // Suponiendo que el endpoint devuelve 200 en caso de éxito
      return true;
    } else {
      print('Error al activar comercio: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  Future<bool> deactivateCommerce(String token, int commerceId) async {
    final url = Uri.parse('$baseUrl/user/commerces/$commerceId/deactivate');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) { // Suponiendo que el endpoint devuelve 200 en caso de éxito
      return true;
    } else {
      print('Error al desactivar comercio: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  Future<bool> updateCommerce(String token, int commerceId, Map<String, dynamic> commerceData) async {
    final url = Uri.parse('$baseUrl/user/commerces/$commerceId');

    // Imprimir la URL y datos importantes para la depuración
    print('URL de la solicitud: $url');
    print('Commerce ID: $commerceId');
    print('Headers: ${{
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    }}');
    print('Body: ${jsonEncode(commerceData)}');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(commerceData),
    );

    print('Código de estado: ${response.statusCode}');
    print('Respuesta del servidor: ${response.body}');

    if (response.statusCode == 200) { // Suponiendo que el endpoint devuelve 200 en caso de éxito
      return true;
    } else {
      print('Error al actualizar comercio: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

}
