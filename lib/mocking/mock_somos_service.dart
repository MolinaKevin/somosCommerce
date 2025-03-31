class MockSomosService {
  Future<List<Map<String, dynamic>>> fetchSomosOptions(String token) async {
    await Future.delayed(Duration(milliseconds: 500));
    return [
      {
        'id': 1,
        'name': 'Potsdam'
      },
      {
        'id': 2,
        'name': 'Berlin'
      },
      {
        'id': 3,
        'name': 'Lübeck'
      },
    ];
  }
}
