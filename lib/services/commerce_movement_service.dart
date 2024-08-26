import 'dart:convert';
import 'package:http/http.dart' as http;

class CommerceMovementService {
  static const String baseUrl = 'http://localhost/api'; // Cambia a tu URL de API real

  Future<List<Map<String, dynamic>>> fetchPurchases(String token, int commerceId) async {
    final url = Uri.parse('$baseUrl/user/commerces/$commerceId/purchases');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Aquí asumimos que la respuesta tiene una estructura similar a {"data": [...]}
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } else {
      print('Error al obtener compras: ${response.statusCode} - ${response.body}');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchDonations(String token, int commerceId) async {
    final url = Uri.parse('$baseUrl/user/commerces/$commerceId/donations');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } else {
      print('Error al obtener donaciones: ${response.statusCode} - ${response.body}');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchCashouts(String token, int commerceId) async {
    final url = Uri.parse('$baseUrl/user/commerces/$commerceId/cashouts');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } else {
      print('Error al obtener cashouts: ${response.statusCode} - ${response.body}');
      return [];
    }
  }
}
