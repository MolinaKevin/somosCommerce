import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageUploadService {

  String buildUploadUrl(String entityType, int id) {
    if (entityType == 'commerce' || entityType == 'nro') {
      return 'http://localhost/api/${entityType}s/$id/upload-image';
    } else {
      throw ArgumentError('Tipo de entidad no soportado: $entityType');
    }
  }

  Future<String?> uploadImage(File imageFile, String entityType, int entityId, String authToken) async {
    try {
      String apiUrl = buildUploadUrl(entityType, entityId);

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));


      request.headers['Authorization'] = 'Bearer $authToken';


      request.files.add(await http.MultipartFile.fromPath('foto', imageFile.path));

      var response = await request.send();


      print('Código de estado de la respuesta: ${response.statusCode}');
      print('Encabezados de la respuesta: ${response.headers}');

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var decodedResponse = json.decode(responseData);
        return decodedResponse['url'];
      } else if (response.statusCode == 302) {

        print('Redirección a: ${response.headers['location']}');
        return null;
      } else {
        print('Error al subir imagen: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error en la subida de la imagen: $e');
      return null;
    }
  }


  Future<String?> uploadImageUrl(String imageUrl, String entityType, int entityId, String authToken) async {
    try {
      String apiUrl = buildUploadUrl(entityType, entityId) + '-url';

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({'imageUrl': imageUrl}),
      );

      print('Código de estado de la respuesta: ${response.statusCode}');
      print('Encabezados de la respuesta: ${response.headers}');

      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);
        return decodedResponse['url'];
      } else if (response.statusCode == 302) {
        print('Redirección a: ${response.headers['location']}');
        return null;
      } else {
        print('Error al subir imagen desde URL: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al subir imagen desde URL: $e');
      return null;
    }
  }
}
