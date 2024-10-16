import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageUploadService {

  // Método para construir la URL dinámica
  String buildUploadUrl(String entityType, int id) {
    if (entityType == 'commerce' || entityType == 'nro') {
      return 'http://localhost/api/${entityType}s/$id/upload-image';
    } else {
      throw ArgumentError('Tipo de entidad no soportado: $entityType');
    }
  }

  // Método para subir una imagen al servidor
  Future<String?> uploadImage(File imageFile, String entityType, int entityId, String authToken) async {
    try {
      // Construye la URL usando la función buildUploadUrl
      String apiUrl = buildUploadUrl(entityType, entityId);

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Incluye el token en la cabecera de autorización
      request.headers['Authorization'] = 'Bearer $authToken';

      // Agrega la imagen con el nombre del campo correcto ('foto')
      request.files.add(await http.MultipartFile.fromPath('foto', imageFile.path));

      var response = await request.send();

      // Capturar detalles de la respuesta
      print('Código de estado de la respuesta: ${response.statusCode}');
      print('Encabezados de la respuesta: ${response.headers}');

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var decodedResponse = json.decode(responseData);
        return decodedResponse['url']; // Retorna la URL de la imagen subida
      } else if (response.statusCode == 302) {
        // Mostrar la URL de redirección para entender mejor qué está pasando
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

  // Método para manejar imágenes enviadas por URL
  Future<String?> uploadImageUrl(String imageUrl, String entityType, int entityId, String authToken) async {
    try {
      String apiUrl = buildUploadUrl(entityType, entityId) + '-url';

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken', // Incluye el token
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
