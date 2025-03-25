import 'dart:convert';

class MockCategoryService {
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    const mockResponse = '''
    [
      {"id": 1, "name": "Electronics"},
      {"id": 2, "name": "Groceries"},
      {"id": 3, "name": "Clothing"}
    ]
    ''';

    await Future.delayed(Duration(seconds: 1));
    return List<Map<String, dynamic>>.from(json.decode(mockResponse));
  }
}
