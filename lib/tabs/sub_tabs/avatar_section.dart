import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../helpers/translations_helper.dart'; // Asegúrate de importar el helper de traducción

class AvatarSection extends StatelessWidget {
  final TextEditingController avatarController;
  final Function onPickImage;
  final Function onEnterAvatarUrl;

  AvatarSection({
    required this.avatarController,
    required this.onPickImage,
    required this.onEnterAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(avatarController.text),
          onBackgroundImageError: (_, __) {
            print('Error al cargar la imagen del avatar');
          },
        ),
        SizedBox(height: 8),
        CupertinoButton.filled(
          child: Text(translate(context, 'changeAvatar') ?? 'Cambiar Avatar'),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.photo),
                        title: Text(translate(context, 'uploadFromGallery') ?? 'Subir desde la galería'),
                        onTap: () {
                          onPickImage();
                          Navigator.of(context).pop();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.link),
                        title: Text(translate(context, 'enterUrl') ?? 'Ingresar URL'),
                        onTap: () {
                          onEnterAvatarUrl();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
