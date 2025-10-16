class ImmobilePost {
  final String? name;
  final int? number;
  final String? type;
  final String? location;
  final String? neighborhood;
  final String? city;
  final String? reference;
  final double? value;
  final int? numberOfBedrooms;
  final int? numberOfBathrooms;
  final bool? garagem;
  final String? description;
  final int? proprietaryId;

  ImmobilePost({
    this.name,
    this.number,
    this.type,
    this.location,
    this.neighborhood,
    this.city,
    this.reference,
    this.value,
    this.numberOfBedrooms,
    this.numberOfBathrooms,
    this.garagem,
    this.description,
    this.proprietaryId,
  });

  /// Cria uma instância de ImmobilePost a partir de um Map.
  /// O map deve conter as chaves correspondentes aos atributos da classe.
  /// Caso alguma chave não exista, o valor será `null`.
  factory ImmobilePost.fromMap(Map<String, dynamic> map) {
    return ImmobilePost(
      name: map['name'],
      number: map['number'],
      type: map['type'],
      location: map['location'],
      neighborhood: map['neighborhood'],
      city: map['city'],
      reference: map['reference'],
      value: map['value'],
      numberOfBedrooms: map['numberOfBedrooms'],
      numberOfBathrooms: map['numberOfBathrooms'],
      garagem: map['garagem'],
      description: map['description'],
      proprietaryId: map['proprietaryId'],
    );
  }

  /// Converte a instância atual de ImmobilePost em um Map.
  /// Retorna um mapa onde cada chave representa o nome do atributo
  /// e o valor corresponde ao conteúdo do campo.
  Map<String, dynamic> toMap() {
    return {
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
    };
  }
}
