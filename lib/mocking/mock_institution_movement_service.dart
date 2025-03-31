class MockInstitutionMovementService {
  Future<List<Map<String, dynamic>>> fetchDonations(String token, int institutionId) async {
    return [
      {
        'id': 1,
        'donor_name': 'Comercio X',
        'points': 100,
        'created_at': '2024-12-01T14:30:00Z',
        'is_paid': 1,
      },
      {
        'id': 2,
        'donor_name': 'Comercio Y',
        'points': 80,
        'created_at': '2024-12-02T10:00:00Z',
        'is_paid': 0,
      },
    ];
  }

  Future<List<Map<String, dynamic>>> fetchContributions(String token, int institutionId) async {
    return [
      {
        'id': 1,
        'recipient_name': 'Beneficiario A',
        'points': 50,
        'created_at': '2024-12-03T12:00:00Z',
        'is_paid': 1,
      },
      {
        'id': 2,
        'recipient_name': 'Beneficiario B',
        'points': 70,
        'created_at': '2024-12-04T15:30:00Z',
        'is_paid': 0,
      },
    ];
  }
}
