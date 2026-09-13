class ApiConstants {
  static const String baseUrl = 'https://api.thedogapi.com/v1';
  
  // Se obtiene la API Key en tiempo de compilación con --dart-define=DOG_API_KEY=tu_llave
  // Si no se especifica, se utiliza la llave por defecto para el desarrollo local
  static const String apiKey = String.fromEnvironment(
    'DOG_API_KEY',
    defaultValue: '',
  );

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
