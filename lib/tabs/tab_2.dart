import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/commerce_movement_service.dart';
import '../services/auth_service.dart';
import '../helpers/translations_helper.dart';

class Tab2 extends StatefulWidget {
  final Map<String, dynamic> entity;

  Tab2({required this.entity});

  @override
  _Tab2State createState() => _Tab2State();
}

class _Tab2State extends State<Tab2> {
  String selectedFilter = 'all';
  List<Map<String, dynamic>> movements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovements();
  }

  Future<void> _loadMovements() async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();

      if (token != null) {
        final purchases = await CommerceMovementService().fetchPurchases(token, widget.entity['id']);
        final donations = await CommerceMovementService().fetchDonations(token, widget.entity['id']);
        final cashouts = await CommerceMovementService().fetchCashouts(token, widget.entity['id']);

        setState(() {
          movements = [
            ...purchases.map((purchase) => {...purchase, 'type': 'purchase'}),
            ...donations.map((donation) => {...donation, 'type': 'donation'}),
            ...cashouts.map((cashout) => {...cashout, 'type': 'cashout'}),
          ];

          movements.sort((a, b) {
            final dateA = DateTime.parse(a['created_at']);
            final dateB = DateTime.parse(b['created_at']);
            return dateB.compareTo(dateA);
          });

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(translate(context, 'errors.authTokenError') ?? 'Could not obtain the authentication token')),
        );
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate(context, 'movements.movementsLoadError') ?? 'Error loading movements: $error')),
      );
    }
  }

  List<Map<String, dynamic>> getFilteredMovements() {
    if (selectedFilter == 'all') {
      return movements;
    }
    return movements.where((movement) {
      return movement['type'] == selectedFilter;
    }).toList();
  }

  Color _getBackgroundColor(String type) {
    switch (type) {
      case 'purchase':
        return Colors.blue.shade50;
      case 'donation':
        return Colors.green.shade50;
      case 'cashout':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  String _getMovementDescription(Map<String, dynamic> movement) {
    String formatDate(String? date) {
      if (date == null) return translate(context, 'movements.notAvailable') ?? 'N/A';
      try {
        final parsedDate = DateTime.parse(date);
        return DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
      } catch (e) {
        return translate(context, 'errors.invalidDate') ?? 'Invalid date';
      }
    }

    switch (movement['type']) {
      case 'purchase':
        return '${translate(context, 'points.pass') ?? 'Pass'}: ${movement['user_pass'] ?? 'N/A'}\n${translate(context, 'time.date') ?? 'Date'}: ${formatDate(movement['created_at'])}';
      case 'donation':
        return '${translate(context, 'movements.donationTo') ?? 'Donation to'}: ${movement['donation_number'] ?? 'N/A'}\n${translate(context, 'time.date') ?? 'Date'}: ${formatDate(movement['created_at'])}';
      case 'cashout':
        return '${translate(context, 'time.withdrawalDate') ?? 'Withdrawal date'}: ${formatDate(movement['created_at'])}';
      default:
        return translate(context, 'errors.noDescription') ?? 'No description';
    }
  }

  Widget _buildMovementItem(Map<String, dynamic> movement) {
    bool isPaid = movement['is_paid'] is int ? movement['is_paid'] == 1 : (movement['is_paid'] ?? false);

    return Container(
      color: _getBackgroundColor(movement['type']),
      child: ListTile(
        title: Text(_getMovementDescription(movement)),
        subtitle: Text(_getAmountOrPoints(movement)),
        trailing: isPaid
            ? Icon(Icons.check_circle, color: Colors.green)
            : Icon(Icons.cancel, color: Colors.red),
      ),
    );
  }

  String _getAmountOrPoints(Map<String, dynamic> movement) {
    if (movement['type'] == 'purchase') {
      return '${translate(context, 'points.amount') ?? 'Amount'}: ${movement['amount'] ?? 0}';
    } else {
      return '${translate(context, 'points.points') ?? 'Points'}: ${movement['points'] ?? 0}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredMovements = getFilteredMovements();

    return Scaffold(
      appBar: AppBar(
        title: Text(translate(context, 'movements.commerceMovements') ?? 'Business Movements'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  TextButton(
                    child: Text(translate(context, 'movements.all') ?? 'All'),
                    onPressed: () {
                      setState(() {
                        selectedFilter = 'all';
                      });
                    },
                  ),
                  TextButton(
                    child: Text(translate(context, 'movements.purchases') ?? 'Purchases'),
                    onPressed: () {
                      setState(() {
                        selectedFilter = 'purchase';
                      });
                    },
                  ),
                  TextButton(
                    child: Text(translate(context, 'movements.donations') ?? 'Donations'),
                    onPressed: () {
                      setState(() {
                        selectedFilter = 'donation';
                      });
                    },
                  ),
                  TextButton(
                    child: Text(translate(context, 'movements.closures') ?? 'Closures'),
                    onPressed: () {
                      setState(() {
                        selectedFilter = 'cashout';
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredMovements.isEmpty
                ? Center(child: Text(translate(context, 'movements.noMovements') ?? 'No movements available'))
                : ListView.builder(
              itemCount: filteredMovements.length,
              itemBuilder: (context, index) {
                return _buildMovementItem(filteredMovements[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
