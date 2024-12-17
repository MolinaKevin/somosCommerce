import 'dart:convert';
import 'package:http/http.dart' as http;

class SealService {
  static const String baseUrl = 'http://localhost/api';

  Future<List<Map<String, dynamic>>> fetchSeals(String token) async {
    final url = Uri.parse('$baseUrl/seals');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Seals obtenidos: $data');

      if (data != null && data['data'] != null && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        print('Estructura inesperada en la respuesta de seals: $data');
        return [];
      }
    } else {
      print('Error al obtener seals: ${response.statusCode} - ${response.body}');
      return [];
    }
  }
}
