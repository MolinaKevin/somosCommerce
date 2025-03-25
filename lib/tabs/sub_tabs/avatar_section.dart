import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../helpers/translations_helper.dart';

class AvatarSection extends StatelessWidget {
  final String avatarUrl;
  final Function onPickImage;
  final Function onEnterAvatarUrl;

  AvatarSection({
    required this.avatarUrl,
    required this.onPickImage,
    required this.onEnterAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey.shade200,
          child: avatarUrl.isNotEmpty
              ? ClipOval(
            child: Image.network(
              avatarUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'lib/mocking/images/test.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                );
              },
            ),
          )
              : Image.asset(
            'lib/mocking/images/test.png',
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),


        SizedBox(height: 8),
        CupertinoButton.filled(
          child: Text(translate(context, 'avatar.changeAvatar') ?? 'Change Avatar'),
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
                        title: Text(translate(context, 'avatar.uploadFromGallery') ?? 'Upload from Gallery'),
                        onTap: () {
                          onPickImage();
                          Navigator.of(context).pop();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.link),
                        title: Text(translate(context, 'avatar.enterUrl') ?? 'Enter URL'),
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
