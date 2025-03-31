import 'dart:convert';

class MockInstitutionService {
  Future<Map<String, dynamic>> fetchInstitutions(String token) async {
    await Future.delayed(Duration(seconds: 1));

    final mockResponse = {
      'data': [
        {
          'id': 1,
          'name': 'Institución de Prueba 1',
          'description': 'Descripción de la Institución de Prueba 1',
          "address": "Beispiel Adr. 115",
          "city": "Berlin",
          "plz": "10115",
          "latitude": "52.5200",
          "longitude": "13.4050",
          "avatar_url": "lib/mocking/images/test.png",
          "background_image": "lib/mocking/images/bg1.jpg",
        },
        {
          'id': 2,
          'name': 'Institución de Prueba 2',
          'description': 'Descripción de la Institución de Prueba 2',
          "address": "Beispiel Adr. 115",
          "city": "Berlin",
          "plz": "10115",
          "latitude": "52.5200",
          "longitude": "13.4050",
          "avatar_url": "lib/mocking/images/test.png",
          "background_image": "lib/mocking/images/bg1.jpg",
        },
      ],
    };

    return mockResponse;
  }

  Future<Map<String, dynamic>?> createInstitution(String token, Map<String, dynamic> institutionData) async {
    await Future.delayed(Duration(seconds: 1));
    institutionData['id'] = 3; // Nuevo ID de prueba
    return institutionData;
  }

  Future<bool> updateInstitution(String token, int institutionId, Map<String, dynamic> institutionData) async {
    await Future.delayed(Duration(seconds: 1));
    return true;
  }

  Future<bool> deactivateInstitution(String token, int institutionId) async {
    await Future.delayed(Duration(seconds: 1));
    return true;
  }

  Future<bool> activateInstitution(String token, int institutionId) async {
    await Future.delayed(Duration(seconds: 1));
    // Simular una activación exitosa
    return true;
  }
}
