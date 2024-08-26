import 'dart:convert';
import 'package:http/http.dart' as http;

class InstitutionService {
  static const String baseUrl = 'http://localhost/api'; // Cambia a tu URL de API real

  Future<Map<String, dynamic>> fetchInstitutions(String token) async {
    final url = Uri.parse('$baseUrl/user/nros');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data is Map<String, dynamic> && data.containsKey('data')) {
        return data;
      } else {
        print('Estructura inesperada en la respuesta (nro): $data');
        return {};
      }
    } else {
      print('Error al obtener instituciones: ${response.statusCode}');
      return {};
    }
  }

  Future<Map<String, dynamic>?> createInstitution(String token, Map<String, dynamic> institutionData) async {
    final url = Uri.parse('$baseUrl/nros');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(institutionData),
    );

    if (response.statusCode == 201) { // 201 Created
      return jsonDecode(response.body);
    } else {
      print('Error al crear institucion: ${response.statusCode} - ${response.body}');
      return null;
    }
  }
}
