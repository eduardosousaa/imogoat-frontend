import 'package:imogoat/models/immobile.dart';

class Favorite {
  int id;
  int userId;
  int immobileId;
  Immobile immobile;
  List<ImmobileImage> images;

  Favorite({
    required this.id,
    required this.userId,
    required this.immobileId,
    required this.immobile,
    required this.images,
  });

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      id: map['id'] ?? 0,
      userId: map['userId'] ?? 0,
      immobileId: map['immobileId'] ?? 0,
      immobile: Immobile.fromMap(map['immobile'] ?? {}),
      images: map['immobile'] != null && map['immobile']['images'] != null
          ? List<ImmobileImage>.from(map['immobile']['images'].map<ImmobileImage>((image) => ImmobileImage.fromMap(image)))
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'immobileId': immobileId,
      'immobile': immobile.toMap(),
      'images': images.map((image) => image.toMap()).toList(),
    };
  }
}

class ImmobileImage {
  int id;
  String url;

  ImmobileImage({
    required this.id,
    required this.url,
  });

  // Método para converter um Map em uma instância de ImmobileImage
  factory ImmobileImage.fromMap(Map<String, dynamic> map) {
    return ImmobileImage(
      id: map['id'] ?? 0,
      url: map['url'] ?? "https://storage.googleapis.com/imogoat-oficial-ab14c.appspot.com/imoveis/default_image.jpg",
    );
  }

  // Método toMap (opcional) para converter uma instância de ImmobileImage em um Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
    };
  }
}
