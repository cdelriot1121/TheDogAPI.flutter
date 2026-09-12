import 'breed_model.dart';

class DogImageModel {
  final String id;
  final String url;
  final int? width;
  final int? height;
  final List<BreedModel> breeds;

  DogImageModel({
    required this.id,
    required this.url,
    this.width,
    this.height,
    required this.breeds,
  });

  factory DogImageModel.fromJson(Map<String, dynamic> json) {
    List<BreedModel> breedsList = [];
    if (json['breeds'] is List) {
      breedsList = (json['breeds'] as List)
          .map((b) => BreedModel.fromJson(b as Map<String, dynamic>))
          .toList();
    }

    return DogImageModel(
      id: json['id']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      width: json['width'] is int ? json['width'] : null,
      height: json['height'] is int ? json['height'] : null,
      breeds: breedsList,
    );
  }
}
