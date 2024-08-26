import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'commerce_service.dart';
import 'institution_service.dart';

enum AuthStatus { Unauthenticated, Authenticating, Authenticated }

class AuthService with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  AuthStatus _authStatus = AuthStatus.Unauthenticated;
  List<Map<String, dynamic>> _commerces = [];
  List<Map<String, dynamic>> _institutions = [];

  AuthStatus get authStatus => _authStatus;
  bool get isAuth => _authStatus == AuthStatus.Authenticated;

  List<Map<String, dynamic>> get commerces => _commerces;
  List<Map<String, dynamic>> get institutions => _institutions;

  // Método para obtener el token de autenticación
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<bool> tryAutoLogin() async {
    print('Intentando auto-login...');
    final token = await getToken();

    if (token != null) {
      _authStatus = AuthStatus.Authenticated;
      notifyListeners();
      print('Auto-login exitoso. Token encontrado.');

      // Después de un auto-login exitoso, obtenemos comercios e instituciones
      await _fetchUserEntities(token);

      return true;
    }

    _authStatus = AuthStatus.Unauthenticated;
    notifyListeners();
    print('No se encontró token. Redirigiendo a Login.');
    return false;
  }

  Future<bool> login(String email, String password) async {
    _authStatus = AuthStatus.Authenticating;
    notifyListeners();

    // Simula la autenticación - aquí harías la solicitud a tu API
    await Future.delayed(Duration(seconds: 2)); // Simula un retraso en la autenticación

    // Aquí debes manejar el resultado real de tu API
    final token = 'dummy_token'; // Este sería el token real devuelto por tu API
    await _secureStorage.write(key: 'auth_token', value: token);

    _authStatus = AuthStatus.Authenticated;
    notifyListeners();

    // Después de un login exitoso, obtenemos comercios e instituciones
    await _fetchUserEntities(token);

    return true;
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'auth_token');
    _authStatus = AuthStatus.Unauthenticated;
    _commerces = [];
    _institutions = [];
    notifyListeners();
  }

  Future<void> clearAuthToken() async {
    await _secureStorage.delete(key: 'auth_token');
    print("Token de autenticación eliminado");
  }

  Future<void> _fetchUserEntities(String token) async {
    try {
      final commerceService = CommerceService();
      final institutionService = InstitutionService();

      // Obtener los comercios del usuario
      final commerceResponse = await commerceService.fetchCommerces(token);
      if (commerceResponse != null && commerceResponse['data'] != null && commerceResponse['data'] is List) {
        _commerces = List<Map<String, dynamic>>.from(commerceResponse['data'] as List);
      } else {
        print('Estructura inesperada en la respuesta (comm): $commerceResponse');
      }

      // Obtener las instituciones del usuario
      final institutionResponse = await institutionService.fetchInstitutions(token);
      if (institutionResponse != null && institutionResponse['data'] != null && institutionResponse['data'] is List) {
        _institutions = List<Map<String, dynamic>>.from(institutionResponse['data'] as List);
      } else {
        print('Estructura inesperada en la respuesta (nro): $institutionResponse');
      }

      notifyListeners();
    } catch (error) {
      print('Error al obtener entidades del usuario: $error');
    }
  }

}
