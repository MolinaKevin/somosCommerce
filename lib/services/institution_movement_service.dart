import 'dart:convert';
import 'package:http/http.dart' as http;

class InstitutionMovementService {
  static const String baseUrl = 'http://localhost/api';

  Future<List<Map<String, dynamic>>> fetchDonations(String token, int institutionId) async {
    final url = Uri.parse('$baseUrl/user/nros/$institutionId/donations');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } else {
      print('Error al obtener donaciones recibidas: ${response.statusCode} - ${response.body}');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchContributions(String token, int institutionId) async {
    final url = Uri.parse('$baseUrl/user/nros/$institutionId/contributions');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } else {
      print('Error al obtener contribuciones: ${response.statusCode} - ${response.body}');
      return [];
    }
  }
}
