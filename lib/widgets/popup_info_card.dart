import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/seal_icon_widget.dart';

class InfoCardPopup {
  static void show({
    required BuildContext context,
    required Map<String, dynamic> data,
    required Map<String, dynamic> translations,
    required List<Map<String, dynamic>> allSeals,
    required VoidCallback onDismiss,
  }) {
    final sealsWithStateData = data['seals_with_state'];

    final hasSeals = sealsWithStateData != null && sealsWithStateData is List && sealsWithStateData.isNotEmpty;
    print('[InfoCardPopup] Seals with state: $sealsWithStateData');

    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: MediaQuery.of(context).size.height * 0.05,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              child: Image.asset(
                                data['background_image'] ?? '',
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 78,
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 36,
                                  backgroundImage: AssetImage(data['avatar_url'] ?? ''),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          data['is_open'] == true ? Icons.check : Icons.close,
                                          size: 18,
                                          color: data['is_open'] == true ? Colors.green : Colors.red,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          data['is_open'] == true
                                              ? (translations['entities']?['open'] ?? 'Open')
                                              : (translations['entities']?['closed'] ?? 'Closed'),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: data['is_open'] == true ? Colors.green : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      data['name'] ?? 'No name',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (hasSeals)
                                Container(
                                  margin: const EdgeInsets.only(left: 8.0),
                                  child: Row(
                                    children: List<Map<String, dynamic>>.from(sealsWithStateData)
                                        .where((seal) =>
                                    seal['state'] == 'partial' || seal['state'] == 'full')
                                        .map((sealState) {
                                      final sealId = sealState['id'];
                                      final state = sealState['state'];

                                      final matched = allSeals.firstWhere(
                                            (s) => s['id'] == sealId,
                                        orElse: () {
                                          print('[InfoCardPopup] No seal found with id $sealId');
                                          return {};
                                        },
                                      );

                                      if (matched.isEmpty) return SizedBox.shrink();

                                      final completeSeal = {
                                        ...matched,
                                        'state': state,
                                      };

                                      print('[InfoCardPopup] Passing seal to widget: $completeSeal');

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: SealIconWidget(seal: completeSeal),
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(begin: Offset(0, 1), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      ),
    ).then((_) => onDismiss());
  }
}
