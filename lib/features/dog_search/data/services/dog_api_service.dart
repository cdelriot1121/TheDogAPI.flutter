import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../models/breed_model.dart';
import '../models/dog_image_model.dart';

class DogApiException implements Exception {
  final String message;
  final int? statusCode;

  DogApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class DogApiService {
  final http.Client _client;

  DogApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Pantalla 2 Endpoint: GET /breeds/search?q={query}
  Future<List<BreedModel>> searchBreeds(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return [];
    }

    final url = Uri.parse(ApiConstants.searchBreedsUrl(cleanQuery));

    try {
      final response = await _client.get(
        url,
        headers: ApiConstants.headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((item) => BreedModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 429) {
        throw DogApiException(
          '¡Límite de peticiones excedido (429)! Por favor espera unos momentos antes de realizar otra búsqueda.',
          statusCode: 429,
        );
      } else {
        throw DogApiException(
          'Error al buscar razas (Código ${response.statusCode}). Por favor intente más tarde.',
          statusCode: response.statusCode,
        );
      }
    } on DogApiException {
      rethrow;
    } catch (e) {
      throw DogApiException(
        'Error de conexión a la API. Comprueba tu conexión a Internet o intentalo más tarde.',
      );
    }
  }

  /// Pantalla 3 Endpoint: GET /images/{image_id}
  Future<DogImageModel?> getImageDetails(String imageId) async {
    if (imageId.isEmpty) return null;

    final url = Uri.parse(ApiConstants.imageDetailUrl(imageId));

    try {
      final response = await _client.get(
        url,
        headers: ApiConstants.headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        return DogImageModel.fromJson(jsonMap);
      } else if (response.statusCode == 429) {
        throw DogApiException(
          '¡Límite de peticiones excedido (429)!',
          statusCode: 429,
        );
      }
      return null;
    } catch (e) {
      // Si falla la petición de detalle de imagen, se puede seguir mostrando el Breed original
      return null;
    }
  }
}
