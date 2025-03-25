import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/institution_movement_service.dart';
import '../services/auth_service.dart';
import '../helpers/translations_helper.dart';

class TabInstitution2 extends StatefulWidget {
  final Map<String, dynamic> entity;

  TabInstitution2({required this.entity});

  @override
  _TabInstitution2State createState() => _TabInstitution2State();
}

class _TabInstitution2State extends State<TabInstitution2> {
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
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getToken();

      if (token != null) {
        final donationsReceived = await InstitutionMovementService().fetchDonations(token, widget.entity['id']);
        final contributionsMade = await InstitutionMovementService().fetchContributions(token, widget.entity['id']);

        setState(() {
          movements = [
            ...donationsReceived.map((donation) => {...donation, 'type': 'donation_received'}),
            ...contributionsMade.map((contribution) => {...contribution, 'type': 'contribution_made'}),
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
      case 'donation_received':
        return Colors.green.shade50;
      case 'contribution_made':
        return Colors.blue.shade50;
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
      case 'donation_received':
        return '${translate(context, 'movements.donationFrom') ?? 'Donation from'}: ${movement['donor_name'] ?? 'N/A'}\n${translate(context, 'time.date') ?? 'Date'}: ${formatDate(movement['created_at'])}';
      case 'contribution_made':
        return '${translate(context, 'movements.contributionTo') ?? 'Contribution to'}: ${movement['recipient_name'] ?? 'N/A'}\n${translate(context, 'time.date') ?? 'Date'}: ${formatDate(movement['created_at'])}';
      default:
        return translate(context, 'errors.noDescription') ?? 'No description';
    }
  }

  String _getAmountOrPoints(Map<String, dynamic> movement) {
    return '${translate(context, 'points.points') ?? 'Points'}: ${movement['points'] ?? 0}';
  }

  Widget _buildMovementItem(Map<String, dynamic> movement) {
    return Container(
      color: _getBackgroundColor(movement['type']),
      child: ListTile(
        title: Text(_getMovementDescription(movement)),
        subtitle: Text(_getAmountOrPoints(movement)),
        trailing: movement['is_paid'] == 1
            ? Icon(Icons.check_circle, color: Colors.green)
            : Icon(Icons.cancel, color: Colors.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredMovements = getFilteredMovements();

    return Scaffold(
      appBar: AppBar(
        title: Text(translate(context, 'movements.institutionMovements') ?? 'Institution Movements'),
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
                    child: Text(translate(context, 'movements.donationsReceived') ?? 'Donations Received'),
                    onPressed: () {
                      setState(() {
                        selectedFilter = 'donation_received';
                      });
                    },
                  ),
                  TextButton(
                    child: Text(translate(context, 'movements.contributionsMade') ?? 'Contributions Made'),
                    onPressed: () {
                      setState(() {
                        selectedFilter = 'contribution_made';
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
