import 'dart:convert';
import '../services/commerce_service.dart';

class MockCommerceService implements CommerceService {
  @override
  Future<Map<String, dynamic>> fetchCommerces(String token) async {
    const mockResponse = '''
    {
      "data": [
        {
    "id": 1,
    "name": "Test Geschäft 1",
    "description": "Beschreibung 1",
    "address": "Beispiel Adr. 115",
    "city": "Berlin",
    "plz": "10115",
    "latitude": "52.5200",
    "longitude": "13.4050",
    "avatar_url": "lib/mocking/images/test.png",
    "background_image": "lib/mocking/images/bg1.jpg",
    "fotos_urls":
    [
      "lib/mocking/images/bg3.jpg",
      "lib/mocking/images/bg4.jpeg"
    ],
    "percent": "5.0",
    "telephone": "15151515"
  },
  {
    "id": 2,
    "name": "Test Geschäft 2",
    "description": "Beschreibung 2",
    "address": "Beispiel Adr. 9",
    "city": "Hamburg",
    "plz": "20095",
    "latitude": "53.5511",
    "longitude": "9.9937",
    "avatar_url": "lib/mocking/images/test.png",
    "background_image": "lib/mocking/images/bg2.jpg",
    "fotos_urls":
    [
      "lib/mocking/images/bg5.jpg"
    ],
    "percent": "3.5",
    "telephone": "15151515"
  }
      ]
    }
    ''';

    await Future.delayed(Duration(seconds: 1));
    return json.decode(mockResponse);
  }

  @override
  Future<Map<String, dynamic>?> createCommerce(String token, Map<String, dynamic> commerceData) async {
    const mockCreatedCommerce = '''
    {
      "id": 3,
      "name": "Nuevo Comercio de Prueba",
      "description": "Descripción del Nuevo Comercio de Prueba",
      "avatar_url": "lib/mocking/images/test.png"
    }
    ''';

    await Future.delayed(Duration(seconds: 1));
    return json.decode(mockCreatedCommerce);
  }

  @override
  Future<bool> activateCommerce(String token, int commerceId) async {
    await Future.delayed(Duration(seconds: 1));
    return true;
  }

  @override
  Future<bool> deactivateCommerce(String token, int commerceId) async {
    await Future.delayed(Duration(seconds: 1));
    return true;
  }

  @override
  Future<bool> updateCommerce(String token, int commerceId, Map<String, dynamic> commerceData) async {
    await Future.delayed(Duration(seconds: 1));
    return true;
  }
}
