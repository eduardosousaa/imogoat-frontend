import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:imogoat/components/appBarCliente.dart';
import 'package:imogoat/components/textInput.dart';
import 'package:imogoat/controllers/immobile_controller.dart';
import 'package:imogoat/models/immobile_post.dart';
import 'package:imogoat/models/rest_client.dart';
import 'package:imogoat/repositories/immobile_repository.dart';
import 'package:imogoat/styles/color_constants.dart';

class StepTwoCreateImmobilePage extends StatefulWidget {
  const StepTwoCreateImmobilePage({super.key});

  @override
  State<StepTwoCreateImmobilePage> createState() => _CreateImmobilePageState();
}

class _CreateImmobilePageState extends State<StepTwoCreateImmobilePage> {
  final _formKey = GlobalKey<FormState>();
  final _location = TextEditingController();
  final _bairro = TextEditingController();
  final _city = TextEditingController();
  final _reference = TextEditingController();
  ImmobilePost immobile_post = ImmobilePost();

  final controller = ControllerImmobile(
      immobileRepository: ImmobileRepository(restClient: GetIt.I.get<RestClient>()));

  @override
  void dispose() {
    _location.dispose();
    _bairro.dispose();
    _city.dispose();
    _reference.dispose();
    super.dispose();
  }

  Future<void> _showDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Dados Inválidos', 
          style: TextStyle(
            color: verde_black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Poppins',
          )),
          content: const Text('Preencha todos os campos corretamente!',
          style: TextStyle(
            color: verde_medio,
            fontWeight: FontWeight.normal,
            fontSize: 16,
            fontFamily: 'Poppins',
          )),
          actions: [
            TextButton(
              child: const Text('OK', 
              style: TextStyle(
                color: Color(0xFF1F7C70),
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    ImmobilePost immobile_post_aux = arguments?['immobile_data'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: verde_medio,
      ),
      backgroundColor: const Color(0xFFF0F2F5),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Cadastre o seu imóvel',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1F7C70),
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextInput(controller: _location, labelText: 'Localização do imóvel', hintText: 'Ex: Rua do meio',
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'O campo não pode ser vazio';
                    }
                    return null;
                  }),
                  const SizedBox(height: 10),
                  TextInput(controller: _bairro, labelText: 'Bairro', hintText: 'Ex: Parque de Exposição', 
                  keyboardType: TextInputType.name, 
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'O campo não pode ser vazio';
                    }
                    return null;
                  }),
                  const SizedBox(height: 10),
                  TextInput(controller: _city, labelText: 'Cidade', hintText: 'Ex: Picos', 
                  keyboardType: TextInputType.name, 
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'O campo não pode ser vazio';
                    }
                    return null;
                  }),
                  const SizedBox(height: 10),
                  TextInput(controller: _reference, labelText: 'Ponto de Referencia', hintText: 'Ex: Ao lado da UFPI',
                  keyboardType: TextInputType.name, 
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'O campo não pode ser vazio';
                    }
                    return null;
                  }),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 365,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          try {
                            immobile_post = ImmobilePost(name: immobile_post_aux.name, number: immobile_post_aux.number, type: immobile_post_aux.type, location: _location.text, neighborhood: _bairro.text, city: _city.text, reference: _reference.text);
                            print('Immobile 02: ' + immobile_post.toMap().toString());
                            Navigator.pushNamed(context, '/step_three', arguments: {
                              "immobile_data": immobile_post
                            });
                          } catch (error) {
                            print('Erro ao processar o valor: $error');
                            _showDialog(context);
                          }
                        } else {
                          _showDialog(context);
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(const Color(0xFF265C5F)),
                        side: MaterialStateProperty.all(const BorderSide(color: Color(0xFF265C5F), width: 1.5)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        overlayColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.white;
                          }
                          return null;
                        }),
                        elevation: MaterialStateProperty.all(0),
                        minimumSize: MaterialStateProperty.all(const Size(200, 50)),
                      ),
                      child: const Text(
                        'Próximo',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
