import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
          backgroundImage: avatarController.text.isNotEmpty
              ? NetworkImage(avatarController.text)
              : AssetImage('assets/default_avatar.png') as ImageProvider,
        ),
        SizedBox(height: 8),
        CupertinoButton.filled(
          child: Text('Cambiar Avatar'),
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
                        title: Text('Subir desde la galería'),
                        onTap: () {
                          onPickImage();
                          Navigator.of(context).pop();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.link),
                        title: Text('Ingresar URL'),
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
