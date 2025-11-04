import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:imogoat/components/appBarCliente.dart';
import 'package:imogoat/components/textInput.dart';
import 'package:imogoat/controllers/immobile_controller.dart';
import 'package:imogoat/models/immobile_post.dart';
import 'package:imogoat/models/rest_client.dart';
import 'package:imogoat/repositories/immobile_repository.dart';
import 'package:imogoat/styles/color_constants.dart';

class StapeOneCreateImmobilePage extends StatefulWidget {
  const StapeOneCreateImmobilePage({super.key});

  @override
  State<StapeOneCreateImmobilePage> createState() => _CreateImmobilePageState();
}

class _CreateImmobilePageState extends State<StapeOneCreateImmobilePage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _number = TextEditingController();
  final _type = TextEditingController();

  ImmobilePost immobile_post = ImmobilePost();

  final controller = ControllerImmobile(
      immobileRepository: ImmobileRepository(restClient: GetIt.I.get<RestClient>()));

  final Map<String, String> _typeMap = {
    'apartamento': 'apartment',
    'casa': 'house',
    'quitinete': 'studioApartment',
    'pontocomercial': 'commercialPoint',
  };

  @override
  void dispose() {
    _name.dispose();
    _number.dispose();
    _type.dispose();
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

  // Função para obter o valor em inglês a partir do valor em português
  String? _getEnglishType(String? portugueseType) {
    if (portugueseType == null) return null;
    final normalizedType = portugueseType.trim().toLowerCase().replaceAll(' ', '');
    return _typeMap[normalizedType];
  }


  @override
  Widget build(BuildContext context) {
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
                  TextInput(controller: _name, labelText: 'Nome do imóvel', hintText: 'Ex: Apartamento 01', keyboardType: TextInputType.name, 
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'O campo não pode ser vazio';
                    }
                    return null;
                  }),
                  const SizedBox(height: 10),
                  TextInput(controller: _number, labelText: 'Número do imóvel', hintText: 'Ex: 123', keyboardType: TextInputType.number, 
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'O campo não pode ser vazio';
                    }
                    return null;
                  }),
                  const SizedBox(height: 10),
                  TextInput(controller: _type, labelText: 'Tipo do imóvel', hintText: 'Ex: apartamento/casa/quitinete/ponto comercial', keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'O campo não pode ser vazio';
                    }
                    final normalizedValue = value.trim().toLowerCase().replaceAll(' ', '');
                    
                    if (!_typeMap.keys.contains(normalizedValue)) {
                        return 'O nome do imóvel deve ser: apartamento, casa, quitinete ou ponto comercial';
                    }
                    return null;
                  }),
                  const SizedBox(height: 10),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 365,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          try {
                            final englishType = _getEnglishType(_type.text);

                            if (englishType != null) {
                              immobile_post = ImmobilePost(
                                name: _name.text.trim(),
                                number: int.parse(_number.text.trim()),
                                type: englishType,
                              );
                              print('Immobile 01: ' + immobile_post.toMap().toString());
                              Navigator.pushNamed(context, '/step_two', arguments: {
                                "immobile_data": immobile_post
                              });
                            } else {
                              _showDialog(context);
                            }
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