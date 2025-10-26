import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:imogoat/components/loading.dart';
import 'package:imogoat/components/textInput.dart';
import 'package:imogoat/components/passwordInput.dart';
import 'package:imogoat/controllers/user_controller.dart';
import 'package:imogoat/models/rest_client.dart';
import 'package:imogoat/repositories/user_repository.dart';
import 'package:imogoat/styles/color_constants.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final httpCliente = GetIt.I.get<RestClient>();
  final _formKey = GlobalKey<FormState>();
  final controller = ControllerUser(
      userRepository: UserRepository(restClient: GetIt.I.get<RestClient>()));
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _number = TextEditingController();
  final _role = 'user';
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool result = false;

  final phoneMask = MaskTextInputFormatter(
    mask: '(##) # ####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  /// Realiza o processo de cadastro de um novo usuário na aplicação.
  ///
  /// O processo inclui:
  /// 1. Exibir um diálogo de carregamento ([Loading]).
  /// 2. Chamar [controller.signUpUser] para enviar os dados de registro para a API.
  /// 3. Fechar o diálogo de carregamento.
  /// 4. Se o resultado for sucesso (`true`), exibe um diálogo de sucesso ([_showDialog]).
  /// 5. Se o resultado for falha (`false`), exibe um [AlertDialog] com a mensagem de erro.
  /// 6. Em caso de exceção, fecha o diálogo de carregamento e imprime o erro no console.
  ///
  /// Note que a variável `context` é exigida no escopo desta função para interagir com a UI.
  ///
  /// @param username O nome de usuário a ser registrado.
  /// @param email O endereço de e-mail do usuário.
  /// @param password A senha escolhida pelo usuário.
  /// @param phoneNumber O número de telefone do usuário.
  /// @param role O papel ou tipo de usuário (ex: 'proprietário', 'corretor').
  Future<void> register(String username, String email, String password,
      String phoneNumber, String role) async {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Loading();
        },
      );
      result = await controller.signUpUser(
          '/create-user', username, email, password, phoneNumber, role);
      Navigator.pop(context);
      if (result) {
        _showDialog(context);
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Alerta',
                  style: TextStyle(
                    color: verde_black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    fontFamily: 'Poppins',
                  )),
              content: const Text('Não foi possível cadastrar seu Usuário!',
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
          title: const Text('Conta Criada!',
              style: TextStyle(
                color: verde_black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: 'Poppins',
              )),
          content: const Text('Sua conta foi criada com sucesso!',
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
                Navigator.pushReplacementNamed(context, '/');
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
      backgroundColor: background,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  const Text(
                    'Cadastre-se',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 46, 60, 78),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Começar é fácil',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color.fromARGB(255, 46, 60, 78),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 15),

                  const SizedBox(height: 20),

                  // Campos
                  TextInput(
                    controller: _name,
                    labelText: 'Nome completo',
                    hintText: 'Digite seu nome',
                    validator: (value) => value == null || value.isEmpty
                        ? "Informe seu nome"
                        : null,
                  ),
                  const SizedBox(height: 20),
                  TextInput(
                    controller: _email,
                    labelText: 'Email',
                    hintText: 'exemplo@gmail.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, digite um e-mail.';
                      } else if (!RegExp(
                              r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$')
                          .hasMatch(value)) {
                        return 'E-mail inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextInput(
                    controller: _number,
                    labelText: 'Numero',
                    hintText: '(00) 9 9999-9999',
                    keyboardType: TextInputType.number,
                    inputFormatters: [phoneMask],
                  ),
                  const SizedBox(height: 20),
                  PasswordInput(
                    controller: _password,
                    labelText: 'Senha',
                    hintText: 'Digite sua senha',
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  PasswordInput(
                    controller: _confirmPassword,
                    labelText: 'Confirmar senha',
                    hintText: 'Repita sua senha',
                    validator: (value) {
                      if (value != _password.text) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: 365,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          register(
                              _name.text.trim(),
                              _email.text.trim(),
                              _password.text.trim(),
                              _number.text.trim(),
                              _role);
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 24, 157, 130),
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        elevation: MaterialStateProperty.all(0),
                        minimumSize: MaterialStateProperty.all(
                          const Size(200, 50),
                        ),
                      ),
                      child: const Text(
                        'Criar Conta',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                  const Text(
                    "Ao Criar Conta você indica que leu e concordou com os Termos de Uso",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Color.fromARGB(255, 46, 60, 78),
                    ),
                  ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/'),
                    child: const Text.rich(
                      TextSpan(
                        text: 'Já possui uma conta? ',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.black54,
                        ),
                        children: [
                          TextSpan(
                            text: 'Login!',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Color.fromARGB(225, 24, 157, 130),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String text, IconData icon, Color color) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: color),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
