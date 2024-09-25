import 'dart:convert';
import 'package:http/http.dart' as http;

class SomosService {
  static const String baseUrl = 'http://localhost/api'; // Cambia a tu URL de API real

  Future<List<Map<String, dynamic>>> fetchSomosOptions(String token) async {
    final url = Uri.parse('$baseUrl/somos');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } else {
      print('Error al obtener las opciones de Somos: ${response.statusCode} - ${response.body}');
      return [];
    }
  }
}
