import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:thedogapi/features/dog_search/data/models/breed_model.dart';

void main() {
  test('BreedModel parses sample json_busquedaraza correctly', () {
    const sampleJson = '''
    {
        "id": "4",
        "name": "Airedale Terrier",
        "life_span": "11-14",
        "temperament": "Confident, intelligent, courageous, alert, energetic, outgoing",
        "origin": "Yorkshire, England",
        "country_code": "GB",
        "reference_image_id": "QWRBrrIvB",
        "weight": {
            "metric": "Male: 23-32; Female: 18-25"
        },
        "height": {
            "metric": "Male: 58-61; Female: 56-58"
        },
        "image": {
            "id": "QWRBrrIvB",
            "url": "https://cdn2.thedogapi.com/images/QWRBrrIvB.jpg"
        }
    }
    ''';

    final Map<String, dynamic> jsonMap = json.decode(sampleJson);
    final breed = BreedModel.fromJson(jsonMap);

    expect(breed.id, '4');
    expect(breed.name, 'Airedale Terrier');
    expect(breed.lifeSpan, '11-14');
    expect(breed.metricWeight, 'Male: 23-32; Female: 18-25');
    expect(breed.metricHeight, 'Male: 58-61; Female: 56-58');
    expect(breed.imageUrl, 'https://cdn2.thedogapi.com/images/QWRBrrIvB.jpg');
    expect(breed.temperamentTags.length, 6);
    expect(breed.temperamentTags.first, 'Confident');
  });
}
