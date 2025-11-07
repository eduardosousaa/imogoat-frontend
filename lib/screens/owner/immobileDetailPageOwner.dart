import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:imogoat/components/loading.dart';
import 'package:imogoat/controllers/feedback_controller.dart';
import 'package:imogoat/controllers/immobile_controller.dart';
import 'package:imogoat/controllers/user_controller.dart';
import 'package:imogoat/models/immobile_post.dart';
import 'package:imogoat/models/rest_client.dart';
import 'package:imogoat/models/user.dart';
import 'package:imogoat/repositories/feedback_repository.dart';
import 'package:imogoat/repositories/immobile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:imogoat/models/immobile.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:imogoat/styles/color_constants.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ImmobileDetailPageOwner extends StatefulWidget {
  final Immobile immobile;

  const ImmobileDetailPageOwner({Key? key, required this.immobile})
      : super(key: key);

  @override
  _ImmobileDetailPageOwnerState createState() => _ImmobileDetailPageOwnerState();
}

class _ImmobileDetailPageOwnerState extends State<ImmobileDetailPageOwner> {
  String role = '';
  int id = 0;

  final controller = ControllerImmobile(
      immobileRepository:
          ImmobileRepository(restClient: GetIt.I.get<RestClient>()));

  Future<String?> getOwnerPhoneNumber(int ownerId) async {
    final controllerUser = ControllerUser(userRepository: GetIt.I.get());

    await controllerUser.buscarUsers();

    final owner = controllerUser.user.firstWhere(
      (user) => user.id == ownerId,
      orElse: () => User(
        id: 0,
        username: 'Desconhecido',
        email: '',
        phoneNumber: '',
        role: '',
      ),
    );

    return owner.phoneNumber.isNotEmpty ? owner.phoneNumber : null;
  }
  
  final controllerFeedback = ControllerFeedback(
      repository: FeedbackRepository(restClient: GetIt.I.get<RestClient>()));

  @override
  void initState() {
    super.initState();
    getRole();
    controllerFeedback.fetchFeedbacksByImmobile(widget.immobile.id);
  }

  final Map<String, String> _typeTranslations = {
    'house': 'Casa',
    'apartment': 'Apartamento',
    'studioApartment': 'Kitnet',
    'commercialPoint': 'Ponto Comercial',
  };

  Future<void> showFeedbackDialog(
      BuildContext context, int userId, int immobileId) async {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController commentController = TextEditingController();
    double rating = 0;

    final confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Deixe seu Feedback',
            style: TextStyle(
              color: verde_medio,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: 'Poppins',
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        labelText: 'Comentário',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, adicione um comentário.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Avaliação:',
                            style: TextStyle(
                              color: verde_black,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              fontSize: 16,
                            ),
                          ),
                          Slider(
                            value: rating,
                            onChanged: (value) =>
                                setState(() => rating = value),
                            divisions: 5,
                            label: rating.toStringAsFixed(1),
                            min: 0,
                            max: 5,
                            activeColor: verde_medio,
                            inactiveColor: Colors.grey.shade300,
                          ),
                          Text(
                            'Nota: ${rating.toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              color: verde_black,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text(
                'Enviar',
                style: TextStyle(
                  color: verde_medio,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await createFeedback(
        rating,
        commentController.text,
        userId,
        immobileId,
      );
    }
  }

  /// Cria um novo feedback (avaliação) para um imóvel e lida com o fluxo de UI.
  ///
  /// O processo inclui:
  /// 1. Exibir um diálogo de carregamento ([Loading]).
  /// 2. Chamar [controllerFeedback.createFeedback] para enviar os dados. Note que
  ///    o parâmetro [rating] (double) é convertido para `int` antes de ser enviado.
  /// 3. Em caso de sucesso, navega para a rota '/home' e remove todas as rotas
  ///    anteriores (`pushNamedAndRemoveUntil`).
  /// 4. Em caso de erro, o erro é impresso no console e o diálogo de carregamento
  ///    é fechado (`Navigator.pop(context)`).
  ///
  /// @param rating A pontuação (em formato double) dada ao imóvel.
  /// @param comment O comentário ou texto da avaliação.
  /// @param userId O ID do usuário que está enviando o feedback.
  /// @param immobileId O ID do imóvel que está sendo avaliado.
  Future<void> createFeedback(
      double rating, String comment, int userId, int immobileId) async {
    try {
      showDialog(context: context, builder: (context) => const Loading());

      await controllerFeedback.createFeedback(
        rating.toInt(),
        comment,
        userId,
        immobileId,
      );

      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (error) {
      print('Erro ao criar Feedback: $error');
      Navigator.pop(context);
    }
  }

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
                      // CORREÇÃO: Usar a chave 'neighborhood' para o Bairro.
                      neighborhood: controllers['neighborhood']!.text,
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

  /// Atualiza os dados de um imóvel existente e navega para a página principal do proprietário.
  ///
  /// O processo inclui:
  /// 1. Obtém o ID do imóvel a partir do widget (`widget.immobile.id`).
  /// 2. Exibe um diálogo de carregamento ([Loading]).
  /// 3. Chama [controller.updateImmobile] para enviar os novos dados ([data]) para a API.
  /// 4. Em caso de sucesso, navega para a rota '/homeOwner' e remove todas as rotas
  ///    anteriores (`pushNamedAndRemoveUntil`).
  /// 5. Em caso de erro, o erro é impresso no console e o diálogo de carregamento
  ///    é fechado (`Navigator.pop(context)`).
  ///
  /// @param data O objeto [ImmobilePost] contendo os novos dados a serem aplicados ao imóvel.
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          String userId = sharedPreferences.getString('id').toString();
          if (role == 'owner' || role == 'admin') {
            _showEditDialog(context);
          } else {
            showFeedbackDialog(context, int.parse(userId), widget.immobile.id);
          }
        },
        backgroundColor: Color(0xFFFFC107),
        foregroundColor: Colors.white,
        child: const Icon(Icons.edit),
      ),
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
              const SizedBox(
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
                      formattedValue,
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
              const Text(
                'Detalhes da propriedade:',
                style: TextStyle(
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
                    _typeTranslations[widget.immobile.type] ??
                        widget.immobile.type,
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
              const Text(
                'Localização:',
                style: TextStyle(
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
              const Text(
                'Descrição:',
                style: TextStyle(
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
                    onPressed: () async {
                      final phoneNumber =
                          await getOwnerPhoneNumber(widget.immobile.ownerId);

                      if (phoneNumber == null || phoneNumber.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Número do proprietário não disponível')),
                        );
                        return;
                      }
                      final cleanNumber =
                          phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
                      final Uri whatsappUrl = Uri.parse(
                          "https://wa.me/55$cleanNumber?text=${Uri.encodeComponent("Olá! Tenho interesse no imóvel ${widget.immobile.name}.")}");

                      if (await canLaunchUrl(whatsappUrl)) {
                        await launchUrl(whatsappUrl,
                            mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Não foi possível abrir o WhatsApp')),
                        );
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      side: MaterialStateProperty.all(
                        const BorderSide(
                            color: Color.fromARGB(255, 24, 157, 130),
                            width: 1.5),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      overlayColor: MaterialStateProperty.resolveWith<Color?>(
                        (states) => states.contains(MaterialState.pressed)
                            ? const Color.fromARGB(255, 46, 60, 78)
                            : null,
                      ),
                      elevation: MaterialStateProperty.all(0),
                      minimumSize:
                          MaterialStateProperty.all(const Size(200, 50)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        FaIcon(FontAwesomeIcons.whatsapp,
                            color: Color.fromARGB(255, 24, 157, 130)),
                        SizedBox(width: 20),
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
                  )),
              const SizedBox(height: 50),
              // CORREÇÃO DE ESTRUTURA: AQUI COMEÇA O BLOCO DE FEEDBACKS CORRIGIDO.
              const SizedBox(height: 20),
              const Text(
                'Feedbacks:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              AnimatedBuilder(
                animation: controllerFeedback,
                builder: (context, _) {
                  if (controllerFeedback.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controllerFeedback.feedbacks.isEmpty) {
                    return const Text(
                      'Ainda não há feedbacks para este imóvel.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    );
                  }

                  return Column(
                    children: controllerFeedback.feedbacks.map((feedback) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => Icon(
                                    index < feedback.rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                feedback.comment,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}