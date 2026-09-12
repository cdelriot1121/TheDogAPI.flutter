import '../../../../core/constants/api_constants.dart';

class BreedModel {
  final String id;
  final String name;
  final String? lifeSpan;
  final String? temperament;
  final String? origin;
  final String? countryCode;
  final String? description;
  final String? bredFor;
  final String? perfectFor;
  final String? breedGroup;
  final String? history;
  final String? referenceImageId;
  final String? metricWeight;
  final String? imperialWeight;
  final String? metricHeight;
  final String? imperialHeight;
  final String? directImageUrl;

  BreedModel({
    required this.id,
    required this.name,
    this.lifeSpan,
    this.temperament,
    this.origin,
    this.countryCode,
    this.description,
    this.bredFor,
    this.perfectFor,
    this.breedGroup,
    this.history,
    this.referenceImageId,
    this.metricWeight,
    this.imperialWeight,
    this.metricHeight,
    this.imperialHeight,
    this.directImageUrl,
  });

  factory BreedModel.fromJson(Map<String, dynamic> json) {
    // Parse weight map safely
    String? mWeight;
    String? iWeight;
    if (json['weight'] is Map) {
      mWeight = json['weight']['metric']?.toString();
      iWeight = json['weight']['imperial']?.toString();
    }

    // Parse height map safely
    String? mHeight;
    String? iHeight;
    if (json['height'] is Map) {
      mHeight = json['height']['metric']?.toString();
      iHeight = json['height']['imperial']?.toString();
    }

    // Parse nested image safely
    String? imageUrl;
    if (json['image'] is Map && json['image']['url'] != null) {
      imageUrl = json['image']['url'].toString();
    }

    return BreedModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Raza Desconocida',
      lifeSpan: json['life_span']?.toString(),
      temperament: json['temperament']?.toString(),
      origin: json['origin']?.toString(),
      countryCode: (json['country_code'] ?? json['country_codes'])?.toString(),
      description: json['description']?.toString(),
      bredFor: json['bred_for']?.toString(),
      perfectFor: json['perfect_for']?.toString(),
      breedGroup: json['breed_group']?.toString(),
      history: json['history']?.toString(),
      referenceImageId: json['reference_image_id']?.toString(),
      metricWeight: mWeight,
      imperialWeight: iWeight,
      metricHeight: mHeight,
      imperialHeight: iHeight,
      directImageUrl: imageUrl,
    );
  }

  /// Returns the best available image URL for this breed
  String? get imageUrl {
    if (directImageUrl != null && directImageUrl!.isNotEmpty) {
      return directImageUrl;
    }
    if (referenceImageId != null && referenceImageId!.isNotEmpty) {
      return ApiConstants.imageUrlFromId(referenceImageId!);
    }
    return null;
  }

  /// Parsed temperament tags
  List<String> get temperamentTags {
    if (temperament == null || temperament!.isEmpty || temperament == 'unknown') {
      return [];
    }
    return temperament!
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
