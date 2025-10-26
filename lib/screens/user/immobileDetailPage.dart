import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:imogoat/components/loading.dart';
import 'package:imogoat/controllers/immobile_controller.dart';
import 'package:imogoat/models/immobile_post.dart';
import 'package:imogoat/models/rest_client.dart';
import 'package:imogoat/repositories/immobile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:imogoat/models/immobile.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:imogoat/styles/color_constants.dart';
import 'package:intl/intl.dart';

class ImmobileDetailPage extends StatefulWidget {
  final Immobile immobile;

  const ImmobileDetailPage({Key? key, required this.immobile})
      : super(key: key);

  @override
  _ImmobileDetailPageState createState() => _ImmobileDetailPageState();
}

class _ImmobileDetailPageState extends State<ImmobileDetailPage> {
  String role = '';
  int id = 0;

  final controller = ControllerImmobile(
      immobileRepository:
          ImmobileRepository(restClient: GetIt.I.get<RestClient>()));

  @override
  void initState() {
    super.initState();
    getRole();
  }

  final Map<String, String> _typeTranslations = {
    'house': 'Casa',
    'apartment': 'Apartamento',
    'studioApartment': 'Kitnet',
    'commercialPoint': 'Ponto Comercial',
  };

  /// Carrega o papel (role) e o ID do usuário logado a partir do armazenamento local
  /// ([SharedPreferences]) e atualiza o estado do widget.
  ///
  /// O fluxo de operação é:
  /// 1. Obtém o papel ([storedRole]) e o ID ([proprietaryId]) do usuário salvos nas [SharedPreferences].
  /// 2. Imprime os valores no console para fins de depuração.
  /// 3. Atualiza o estado do widget usando [setState], garantindo que:
  ///    - [role] receba [storedRole] (ou uma string vazia como fallback).
  ///    - [id] receba [proprietaryId] convertido para [int] (ou 0 como fallback).
  Future<void> getRole() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? storedRole = sharedPreferences.getString('role');
    String? proprietaryId = sharedPreferences.getString('id');
    print('O tipo de usuário é: $storedRole');
    print('Id do proprietário: $proprietaryId');
    setState(() {
      role = storedRole ?? '';
      id = int.tryParse(proprietaryId ?? '0') ?? 0;
    });
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();

    final controllers = {
      'name': TextEditingController(text: widget.immobile.name),
      'number': TextEditingController(text: widget.immobile.number.toString()),
      'type': TextEditingController(text: widget.immobile.type),
      'location': TextEditingController(text: widget.immobile.location),
      'neighborhood': TextEditingController(text: widget.immobile.neighborhood),
      'city': TextEditingController(text: widget.immobile.city),
      'reference': TextEditingController(text: widget.immobile.reference),
      'value': TextEditingController(text: widget.immobile.value.toString()),
      'bedrooms': TextEditingController(
          text: widget.immobile.numberOfBedrooms.toString()),
      'bathrooms': TextEditingController(
          text: widget.immobile.numberOfBathrooms.toString()),
      'description': TextEditingController(text: widget.immobile.description),
    };

    bool _hasGarage = widget.immobile.garage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Atualizar Imóvel',
            style: TextStyle(
                color: verde_medio,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: 'Poppins'),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var field in controllers.entries)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: field.value,
                        decoration: InputDecoration(labelText: field.key),
                      ),
                    ),
                  StatefulBuilder(
                    builder: (context, setState) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Possui Garagem?',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F7C70))),
                        Switch(
                          value: _hasGarage,
                          activeColor: const Color(0xFF1F7C70),
                          inactiveThumbColor: Colors.grey,
                          inactiveTrackColor: Colors.grey.shade300,
                          onChanged: (value) {
                            setState(() {
                              _hasGarage = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins'),
              ),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
            TextButton(
              child: const Text(
                'Atualizar',
                style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins'),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    final immobilePost = ImmobilePost(
                      name: controllers['name']!.text,
                      number: int.parse(controllers['number']!.text),
                      type: controllers['type']!.text,
                      location: controllers['location']!.text,
                      neighborhood: controllers['bairro']!.text,
                      city: controllers['city']!.text,
                      reference: controllers['reference']!.text,
                      value: double.parse(controllers['value']!.text),
                      numberOfBedrooms:
                          int.parse(controllers['bedrooms']!.text),
                      numberOfBathrooms:
                          int.parse(controllers['bathrooms']!.text),
                      garage: _hasGarage,
                      description: controllers['description']!.text,
                      ownerId: int.parse((await SharedPreferences.getInstance())
                          .getString('id')!),
                    );

                    await updateImmobile(immobilePost);

                    if (mounted && Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    print('Erro ao atualizar imóvel: $e');
                    if (mounted && Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateImmobile(ImmobilePost data) async {
    final String immobileId = widget.immobile.id.toString();
    try {
      showDialog(context: context, builder: (context) => const Loading());
      await controller.updateImmobile('/alter-immobile/$immobileId', data);
      Navigator.pushNamedAndRemoveUntil(
          context, '/homeOwner', (route) => false);
    } catch (error) {
      print('Erro ao atualizar o imóvel: $error');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedValue = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    ).format(widget.immobile.value);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: verde_medio,
      ),
      floatingActionButton: role == 'owner' && id == widget.immobile.ownerId || role == 'admin'
          ? FloatingActionButton(
              backgroundColor: Color(0xFFFFC107),
              foregroundColor: Colors.white,
              child: const Icon(Icons.edit),
              onPressed: () {
                _showEditDialog(context);
              },
            )
          : null,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.immobile.images.isNotEmpty
                  ? CarouselSlider(
                      options: CarouselOptions(
                        height: 400,
                        viewportFraction: 1.0,
                        enlargeCenterPage: true,
                        autoPlay: true,
                      ),
                      items: widget.immobile.images.map((image) {
                        return Builder(
                          builder: (BuildContext context) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                image.url,
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    )
                  : const Text('Imagem indisponível'),
              const SizedBox(height: 16),
              SizedBox(
                width: 400,
                child: Divider(),
              ),
              const SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            '${widget.immobile.name},',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'N° ${widget.immobile.number}',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${formattedValue}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F7C70),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Detalhes da propriedade:',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.house,
                    size: 26,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _typeTranslations[widget.immobile.type] ?? widget.immobile.type, 
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.bed,
                    size: 26,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.immobile.numberOfBedrooms} quartos',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.bathtub,
                    size: 26,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.immobile.numberOfBathrooms} banheiros',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.garage,
                    size: 26,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.immobile.garage == true
                        ? "Com garagem"
                        : "Sem garagem",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Localização:',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 26,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${widget.immobile.location}, ${widget.immobile.neighborhood}, ${widget.immobile.city}, ${widget.immobile.reference}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Descrição:',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.immobile.description,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 365,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    side: MaterialStateProperty.all(
                      const BorderSide(
                        color: Color.fromARGB(255, 24, 157, 130),
                        width: 1.5,
                      ),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    overlayColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Color.fromARGB(255, 46, 60, 78);
                        }
                        return null;
                      },
                    ),
                    elevation: MaterialStateProperty.all(0),
                    minimumSize: MaterialStateProperty.all(const Size(200, 50)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.whatsapp,
                        color: Color.fromARGB(255, 24, 157, 130),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        'Entrar em contato',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Color.fromARGB(255, 24, 157, 130),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
