class MockCommerceMovementService {
  Future<List<Map<String, dynamic>>> fetchPurchases(String token, int commerceId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return [
      {
        "id": 1,
        "user_pass": "ABC123",
        "amount": 150,
        "created_at": "2024-03-16T10:30:00Z",
        "type": "purchase",
        "is_paid": true
      },
      {
        "id": 2,
        "user_pass": "XYZ456",
        "amount": 200,
        "created_at": "2024-03-15T14:20:00Z",
        "type": "purchase",
        "is_paid": false
      }
    ];
  }

  Future<List<Map<String, dynamic>>> fetchDonations(String token, int commerceId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return [
      {
        "id": 3,
        "donation_number": "DON123",
        "points": 50,
        "created_at": "2024-03-14T09:15:00Z",
        "type": "donation",
        "is_paid": true
      }
    ];
  }

  Future<List<Map<String, dynamic>>> fetchCashouts(String token, int commerceId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return [
      {
        "id": 4,
        "created_at": "2024-03-13T11:45:00Z",
        "type": "cashout",
        "is_paid": false
      }
    ];
  }
}
