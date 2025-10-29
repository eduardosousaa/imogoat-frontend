import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:imogoat/components/appBarCliente.dart';
import 'package:imogoat/components/loading.dart';
import 'package:imogoat/components/textInput.dart';
import 'package:imogoat/controllers/user_controller.dart';
import 'package:imogoat/models/rest_client.dart';
import 'package:imogoat/repositories/user_repository.dart';
import 'package:imogoat/styles/color_constants.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmaSenha = TextEditingController();
  final _number = TextEditingController();
  final _role = TextEditingController();
  final controller = ControllerUser(
      userRepository: UserRepository(restClient: GetIt.I.get<RestClient>()));
  bool result = false;

  @override
  void dispose() {
    _username.dispose();
    _number.dispose();
    _email.dispose();
    _password.dispose();
    _confirmaSenha.dispose();
    super.dispose();
  }

  var maskFormatter = MaskTextInputFormatter(
    mask: '(##)# ####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  /// Inicia o processo de cadastro de um novo usuário na aplicação.
  ///
  /// O processo de UI/Lógica inclui:
  /// 1. **Exibir** um diálogo de carregamento ([Loading]) para feedback visual.
  /// 2. Chamar [controller.signUpUser] para enviar os dados de registro para a API.
  /// 3. **Fechar** o diálogo de carregamento.
  /// 4. Se a operação for bem-sucedida (`result = true`), chama [_showDialog]
  ///    (presumivelmente um diálogo de sucesso ou navegação).
  /// 5. Se a operação falhar (`result = false`), exibe um [AlertDialog] com uma
  ///    mensagem de erro ao usuário.
  /// 6. Em caso de exceção, garante que o diálogo de carregamento seja fechado e
  ///    o erro seja impresso no console.
  ///
  /// @param username O nome de usuário para o cadastro.
  /// @param email O endereço de e-mail do usuário.
  /// @param number O número de telefone do usuário.
  /// @param role O papel ou tipo de usuário (ex: 'cliente', 'proprietário').
  /// @param password A senha escolhida pelo usuário.
  Future signUp(String username, String email, String number, String role,
      String password) async {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Loading();
        },
      );
      result = await controller.signUpUser(
          '/create-user', username, email, password, number, role);
      Navigator.pop(context);
      if (result) {
        _showDialog(context);
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Alerta'),
              content: const Text('Não foi possível cadastrar seu Usuário!'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      Navigator.pop(context);
      print(error);
    }
  }

  Future<void> _showDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Usuário Criado!',
              style: TextStyle(
                color: verde_black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: 'Poppins',
              )),
          content: const Text('O usuário foi criado com sucesso!',
              style: TextStyle(
                color: verde_medio,
                fontWeight: FontWeight.normal,
                fontSize: 16,
                fontFamily: 'Poppins',
              )),
          actions: [
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(
                  color: verde_medio,
                  fontWeight: FontWeight.bold,
                  // fontSize: 22,
                  fontFamily: 'Poppins',
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/homeAdm');
              },
            ),
          ],
        );
      },
    );
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
                    'Criar Usuário',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1F7C70),
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextInput(
                      controller: _username,
                      labelText: 'Nome do usuário',
                      hintText: 'Nome',
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'O campo não pode ser vazio';
                        }
                        return null;
                      }),
                  const SizedBox(height: 10),
                  TextInput(
                      controller: _email,
                      labelText: 'Email',
                      hintText: 'exemplo@gmail.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'O campo não pode ser vazio';
                        }
                        return null;
                      }),
                  const SizedBox(height: 10),
                  TextInput(
                      controller: _number,
                      labelText: 'Telefone',
                      hintText: '(89)9 9999-9999',
                      inputFormatters: [maskFormatter],
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'O campo não pode ser vazio';
                        }
                        return null;
                      }),
                  const SizedBox(height: 10),
                  TextInput(
                      controller: _role,
                      labelText: 'Tipo de Usuário',
                      hintText: 'user/owner',
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'O campo não pode ser vazio';
                        }
                        return null;
                      }),
                  const SizedBox(height: 10),
                  TextInput(
                    controller: _password,
                    labelText: 'Senha',
                    hintText: 'Digite sua senha',
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'A senha não pode ser vazia';
                      } else if (value.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextInput(
                    controller: _confirmaSenha,
                    labelText: 'Confirmação de Senha',
                    hintText: 'Confirme sua senha',
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'A confirmação de senha não pode ser vazia';
                      } else if (value != _password.text) {
                        return 'As senhas não são iguais';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: 365,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          signUp(_username.text, _email.text, _number.text,
                              _role.text, _password.text);
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(const Color(0xFF265C5F)),
                        side: MaterialStateProperty.all(const BorderSide(
                            color: Color(0xFF265C5F), width: 1.5)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                        overlayColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.white;
                          }
                          return null;
                        }),
                        elevation: MaterialStateProperty.all(0),
                        minimumSize:
                            MaterialStateProperty.all(const Size(200, 50)),
                      ),
                      child: const Text(
                        'Criar Usuário',
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
