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


    await Future.delayed(Duration(seconds: 2));


    final token = 'dummy_token';
    await _secureStorage.write(key: 'auth_token', value: token);

    _authStatus = AuthStatus.Authenticated;
    notifyListeners();


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


      final commerceResponse = await commerceService.fetchCommerces(token);
      if (commerceResponse != null) {
        if (commerceResponse['data'] != null && commerceResponse['data'] is List) {
          _commerces = List<Map<String, dynamic>>.from(commerceResponse['data'] as List);
        } else {
          print('La respuesta no contiene una lista de comercios en "data". Respuesta completa: $commerceResponse');
        }
      } else {
        print('La respuesta del servidor es nula.');
      }



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
