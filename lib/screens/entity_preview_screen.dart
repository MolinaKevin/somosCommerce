import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/popup_info_card.dart';
import '../services/seal_service.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';

class EntityPreviewScreen extends StatefulWidget {
  final Map<String, dynamic> entity;

  const EntityPreviewScreen({required this.entity});

  @override
  _EntityPreviewScreenState createState() => _EntityPreviewScreenState();
}

class _EntityPreviewScreenState extends State<EntityPreviewScreen> {
  bool _hasShownPopup = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _showInfoPopupIfNeeded();
  }

  Future<void> _showInfoPopupIfNeeded() async {
    if (_hasShownPopup) return;
    _hasShownPopup = true;

    final authService = Provider.of<AuthService>(context, listen: false);
    final token = await authService.getToken();

    if (token != null) {
      final seals = await SealService().fetchSeals(token);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        InfoCardPopup.show(
          context: context,
          data: widget.entity,
          translations: {},
          allSeals: seals,
          onDismiss: () => Navigator.of(context).pop(),
        );
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final latitude = double.tryParse(widget.entity['latitude'].toString()) ?? 0.0;
    final longitude = double.tryParse(widget.entity['longitude'].toString()) ?? 0.0;
    final position = LatLng(latitude, longitude);

    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          center: position,
          zoom: 15,
          interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://abcd.basemaps.cartocdn.com/rastertiles/voyager_labels_under/{z}/{x}/{y}{r}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: position,
                width: 60,
                height: 60,
                child: Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
