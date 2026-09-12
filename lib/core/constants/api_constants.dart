class ApiConstants {
  static const String baseUrl = 'https://api.thedogapi.com/v1';
  
  // Puedes reemplazar esta API Key por la tuya si la tienes
  static const String apiKey = '';

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'x-api-key': apiKey,
  };

  static String searchBreedsUrl(String query) =>
      '$baseUrl/breeds/search?q=$query';

  static String imageDetailUrl(String imageId) =>
      '$baseUrl/images/$imageId';

  static String imageUrlFromId(String imageId) =>
      'https://cdn2.thedogapi.com/images/$imageId.jpg';
}
