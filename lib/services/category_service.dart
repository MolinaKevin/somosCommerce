import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoryService {
  static const String baseUrl = 'http://localhost/api'; // Reemplaza con tu URL de API real

  Future<List<Map<String, dynamic>>> fetchCategories(String token) async {
    final url = Uri.parse('$baseUrl/categories');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Categorías obtenidas: $data');
      return List<Map<String, dynamic>>.from(data);
    } else {
      print('Error al obtener categorías: ${response.statusCode} - ${response.body}');
      return [];
    }
  }
}
