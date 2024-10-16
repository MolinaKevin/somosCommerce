import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/commerce_movement_service.dart';
import '../services/auth_service.dart';
import '../helpers/translations_helper.dart'; // Importar el helper de traducciones

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

          // Ordenar los movimientos por fecha (created_at)
          movements.sort((a, b) {
            final dateA = DateTime.parse(a['created_at']);
            final dateB = DateTime.parse(b['created_at']);
            return dateB.compareTo(dateA); // Orden descendente (más reciente primero)
          });

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(translate(context, 'authTokenError') ?? 'No se pudo obtener el token de autenticación')),
        );
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate(context, 'movementsLoadError') ?? 'Error al cargar los movimientos: $error')),
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
    // Parsear la fecha si existe
    String formatDate(String? date) {
      if (date == null) return translate(context, 'notAvailable') ?? 'N/A';
      try {
        final parsedDate = DateTime.parse(date);
        return DateFormat('dd/MM/yyyy HH:mm').format(parsedDate); // Formato: día/mes/año horas:minutos
      } catch (e) {
        return translate(context, 'invalidDate') ?? 'Fecha inválida';
      }
    }

    switch (movement['type']) {
      case 'purchase':
        return '${translate(context, 'pass') ?? 'Pass'}: ${movement['user_pass'] ?? 'N/A'}\n${translate(context, 'date') ?? 'Fecha'}: ${formatDate(movement['created_at'])}';
      case 'donation':
        return '${translate(context, 'donationTo') ?? 'Donación a'}: ${movement['donation_number'] ?? 'N/A'}\n${translate(context, 'date') ?? 'Fecha'}: ${formatDate(movement['created_at'])}';
      case 'cashout':
        return '${translate(context, 'withdrawalDate') ?? 'Fecha de retiro'}: ${formatDate(movement['created_at'])}';
      default:
        return translate(context, 'noDescription') ?? 'Sin descripción';
    }
  }

  Widget _buildMovementItem(Map<String, dynamic> movement) {
    bool isPaid;

    // Si el valor es int, lo convertimos a bool
    if (movement['is_paid'] is int) {
      isPaid = movement['is_paid'] == 1;
    } else {
      isPaid = movement['is_paid'] ?? false; // Asume false si es null
    }

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
      return '${translate(context, 'amount') ?? 'Monto'}: ${movement['amount'] ?? 0}';
    } else {
      return '${translate(context, 'points') ?? 'Puntos'}: ${movement['points'] ?? 0}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredMovements = getFilteredMovements();

    return Scaffold(
      appBar: AppBar(
        title: Text(translate(context, 'commerceMovements') ?? 'Movimientos del Comercio'), // Modificado
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
                    child: Text(translate(context, 'all') ?? 'Todos'), // Modificado
                    onPressed: () {
                      setState(() {
                        selectedFilter = 'all';
                      });
                    },
                  ),
                  TextButton(
                    child: Text(translate(context, 'purchases') ?? 'Compras'), // Modificado
                    onPressed: () {
                      setState(() {
                        selectedFilter = 'purchase';
                      });
                    },
                  ),
                  TextButton(
                    child: Text(translate(context, 'donations') ?? 'Donaciones'), // Modificado
                    onPressed: () {
                      setState(() {
                        selectedFilter = 'donation';
                      });
                    },
                  ),
                  TextButton(
                    child: Text(translate(context, 'closures') ?? 'Closures'), // Modificado
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
                ? Center(child: Text(translate(context, 'noMovements') ?? 'No hay movimientos disponibles')) // Modificado
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
