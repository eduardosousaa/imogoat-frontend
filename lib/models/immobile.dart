class Immobile {
  int id;
  String name;
  int number;
  String type;
  String location;
  String neighborhood;
  String city;
  String? reference;
  double value;
  int numberOfBedrooms;
  int numberOfBathrooms;
  bool garagem;
  String description;
  int proprietaryId;
  List<ImmobileImage> images;

  Immobile({
    required this.id,
    required this.name,
    required this.number,
    required this.type,
    required this.location,
    required this.neighborhood,
    required this.city,
    this.reference,
    required this.value,
    required this.numberOfBedrooms,
    required this.numberOfBathrooms,
    required this.garagem,
    required this.description,
    required this.proprietaryId,
    required this.images,
  });

  // Método para converter um Map em uma instância de Immobile
  factory Immobile.fromMap(Map<String, dynamic> map) {
    return Immobile(
      id: map['id'] ?? 0, 
      name: map['name'] ?? 'Não informado',
      number: map['number'] ?? 0,
      type: map['type'] ?? 'Não informado',
      location: map['location'] ?? 'Não informado',
      neighborhood: map['neighborhood'] ?? 'Não informado',
      city: map['city'] ?? 'Não informado',
      reference: map['reference'],
      value: (map['value'] as num?)?.toDouble() ?? 0.0,
      numberOfBedrooms: map['numberOfBedrooms'] ?? 0,
      numberOfBathrooms: map['numberOfBathrooms'] ?? 0,
      garagem: map['garagem'] ?? false,
      description: map['description'] ?? 'Descrição não disponível',
      proprietaryId: map['proprietaryId'] ?? 0,
      images: map['images'] != null
          ? List<ImmobileImage>.from(map['images'].map<ImmobileImage>((image) => ImmobileImage.fromMap(image)))
          : [],
    );
  }

  // Método toMap (opcional) para converter uma instância de Immobile em um Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'type': type,
      'location': location,
      'neighborhood': neighborhood,
      'city': city,
      'reference': reference,
      'value': value,
      'numberOfBedrooms': numberOfBedrooms,
      'numberOfBathrooms': numberOfBathrooms,
      'garagem': garagem,
      'description': description,
      'proprietaryId': proprietaryId,
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

