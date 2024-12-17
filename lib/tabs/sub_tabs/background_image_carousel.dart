import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/upload_image_service.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../helpers/translations_helper.dart';

class BackgroundImageCarousel extends StatefulWidget {
  final List<String> backgroundImages;
  final int currentIndex;
  final Function(String?) onImageUploaded;
  final Function(int) onSelectImage;
  final String entityType;
  final int entityId;

  BackgroundImageCarousel({
    required this.backgroundImages,
    required this.currentIndex,
    required this.onImageUploaded,
    required this.onSelectImage,
    required this.entityType,
    required this.entityId,
  });

  @override
  _BackgroundImageCarouselState createState() => _BackgroundImageCarouselState();
}

class _BackgroundImageCarouselState extends State<BackgroundImageCarousel> {
  final ImageUploadService _imageUploadService = ImageUploadService();

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      _uploadImage(imageFile);
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      _uploadImage(imageFile);
    }
  }

  void _showDialog(String title, String message) {
    if (!mounted) return;
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(translate(context, 'ok') ?? 'OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getToken();

      if (token == null) {
        print('Authentication error: Token not retrieved.');
        return;
      }

      String? imageUrl = await _imageUploadService.uploadImage(
        imageFile,
        widget.entityType,
        widget.entityId,
        token,
      );

      if (imageUrl != null) {
        print('Image uploaded: $imageUrl');
        setState(() {
          widget.onImageUploaded(imageUrl);
        });
      } else {
        print('Error uploading image.');
      }

    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _enterImageUrl() async {
    TextEditingController urlController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(translate(context, 'enterBackgroundImageUrl') ?? 'Enter Background Image URL'),
          content: TextField(
            controller: urlController,
            decoration: InputDecoration(hintText: 'https://example.com/background.png'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final token = await _getToken();
                if (token != null) {
                  String? imageUrl = await _imageUploadService.uploadImageUrl(
                    urlController.text,
                    widget.entityType,
                    widget.entityId,
                    token,
                  );

                  if (imageUrl != null) {
                    print('Entered URL: $imageUrl');
                    setState(() {
                      widget.onImageUploaded(imageUrl);
                    });
                    Navigator.of(context).pop();
                  } else {
                    _showDialog(
                      translate(context, 'error') ?? 'Error',
                      translate(context, 'imageUploadError') ?? 'Error uploading image from URL',
                    );
                  }
                }
              },
              child: Text(translate(context, 'save') ?? 'Save'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _getToken() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    return await authService.getToken();
  }

  @override
  Widget build(BuildContext context) {
    print('Current images: ${widget.backgroundImages}');
    print('Selected index: ${widget.currentIndex}');

    return Column(
      children: [
        if (widget.backgroundImages.isEmpty)
          Text(translate(context, 'noImagesAvailable') ?? 'No images available')
        else
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.backgroundImages.length,
              itemBuilder: (context, index) {
                String imageUrl = widget.backgroundImages[index];
                bool isSelectedImage = index == widget.currentIndex;

                print('Displaying image: $imageUrl at index: $index');

                return GestureDetector(
                  onTap: () {
                    print('Image selected: $imageUrl at index: $index');
                    widget.onSelectImage(index);

                    if (index == widget.currentIndex) {
                      widget.onImageUploaded(null);
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelectedImage ? Colors.blue : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey,
                          child: Icon(Icons.broken_image, color: Colors.red),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        CupertinoButton.filled(
          child: Text(translate(context, 'backgroundImage.addBackgroundImage') ?? 'Add Background Image'),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.photo_library),
                        title: Text(translate(context, 'avatar.uploadFromGallery') ?? 'Upload from Gallery'),
                        onTap: () {
                          _pickImageFromGallery();
                          Navigator.of(context).pop();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.link),
                        title: Text(translate(context, 'avatar.enterUrl') ?? 'Enter URL'),
                        onTap: () {
                          _enterImageUrl();
                          Navigator.of(context).pop();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.camera_alt),
                        title: Text(translate(context, 'avatar.takePhoto') ?? 'Take a Photo'),
                        onTap: () {
                          _takePhoto();
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
