import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';


class BackgroundImageCarousel extends StatelessWidget {
  final List<String> backgroundImages;
  final int currentIndex;
  final Function onAddImage;
  final Function onAddImageUrl;
  final Function(int) onSelectImage;

  BackgroundImageCarousel({
    required this.backgroundImages,
    required this.currentIndex,
    required this.onAddImage,
    required this.onAddImageUrl,
    required this.onSelectImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: backgroundImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => onSelectImage(index),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  width: 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: index == currentIndex ? Colors.blue : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: Image.network(backgroundImages[index], fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
        CupertinoButton.filled(
          child: Text('Agregar Imagen de Fondo'),
          onPressed: () async {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.photo_library),
                        title: Text('Subir desde la galería'),
                        onTap: () {
                          onAddImage();
                          Navigator.of(context).pop();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.link),
                        title: Text('Ingresar URL'),
                        onTap: () {
                          onAddImageUrl();
                          Navigator.of(context).pop();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.camera_alt),
                        title: Text('Tomar una foto'),
                        onTap: () {
                          onAddImage();
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
