import 'dart:convert';

class MockInstitutionService {
  Future<Map<String, dynamic>> fetchInstitutions(String token) async {
    // Simular un retraso para imitar una llamada de red
    await Future.delayed(Duration(seconds: 1));

    // Datos de prueba que imitan la estructura de la respuesta real
    final mockResponse = {
      'data': [
        {
          'id': 1,
          'name': 'Institución de Prueba 1',
          'description': 'Descripción de la Institución de Prueba 1',
        },
        {
          'id': 2,
          'name': 'Institución de Prueba 2',
          'description': 'Descripción de la Institución de Prueba 2',
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
