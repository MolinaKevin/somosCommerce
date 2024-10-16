import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/institution_movement_service.dart';
import '../services/auth_service.dart';
import '../helpers/translations_helper.dart'; // Importa el helper de traducciones

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
      final authService = AuthService();
      final token = await authService.getToken();

      if (token != null) {
        final donationsReceived = await InstitutionMovementService().fetchDonations(token, widget.entity['id']);
        final contributionsMade = await InstitutionMovementService().fetchContributions(token, widget.entity['id']);

        setState(() {
          movements = [
            ...donationsReceived.map((donation) => {...donation, 'type': 'donation_received'}),
            ...contributionsMade.map((contribution) => {...contribution, 'type': 'contribution_made'}),
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
      if (date == null) return translate(context, 'notAvailable') ?? 'N/A';
      try {
        final parsedDate = DateTime.parse(date);
        return DateFormat('dd/MM/yyyy HH:mm').format(parsedDate); // Formato: día/mes/año horas:minutos
      } catch (e) {
        return translate(context, 'invalidDate') ?? 'Fecha inválida';
      }
    }

    switch (movement['type']) {
      case 'donation_received':
        return '${translate(context, 'donationFrom') ?? 'Donación de'}: ${movement['donor_name'] ?? 'N/A'}\n${translate(context, 'date') ?? 'Fecha'}: ${formatDate(movement['created_at'])}';
      case 'contribution_made':
        return '${translate(context, 'contributionTo') ?? 'Contribución a'}: ${movement['recipient_name'] ?? 'N/A'}\n${translate(context, 'date') ?? 'Fecha'}: ${formatDate(movement['created_at'])}';
      default:
        return translate(context, 'noDescription') ?? 'Sin descripción';
    }
  }

  String _getAmountOrPoints(Map<String, dynamic> movement) {
    return '${translate(context, 'points') ?? 'Puntos'}: ${movement['points'] ?? 0}';
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
        title: Text(translate(context, 'institutionMovements') ?? 'Movimientos de la Institución'), // Modificado
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
                    child: Text(translate(context, 'donationsReceived') ?? 'Donaciones Recibidas'), // Modificado
                    onPressed: () {
                      setState(() {
                        selectedFilter = 'donation_received';
                      });
                    },
                  ),
                  TextButton(
                    child: Text(translate(context, 'contributionsMade') ?? 'Contribuciones Realizadas'), // Modificado
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
