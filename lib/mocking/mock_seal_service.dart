import 'dart:convert';

class MockSealService {
  Future<List<Map<String, dynamic>>> fetchSeals() async {
    const mockResponse = '''
    [
      {"id": 1, "name": "Eco-friendly"},
      {"id": 2, "name": "Fair Trade"},
      {"id": 3, "name": "Organic"}
    ]
    ''';

    await Future.delayed(Duration(seconds: 1));
    return List<Map<String, dynamic>>.from(json.decode(mockResponse));
  }
}
