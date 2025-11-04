import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:imogoat/components/loading.dart';
import 'package:imogoat/components/textInput.dart';
import 'package:imogoat/components/passwordInput.dart';
import 'package:imogoat/components/signUpPrompt.dart';
import 'package:imogoat/models/rest_client.dart';
import 'package:imogoat/styles/color_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final httpCliente = GetIt.I.get<RestClient>();
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String token = '';
  String role = '';
  int? id_user;
  bool result = false;

  /// Realiza o processo de login do usuário.
  ///
  /// Envia uma requisição POST para a rota `/login` com o email e password.
  /// Caso a autenticação seja bem-sucedida, o token e outras informações
  /// são salvas no SharedPreferences e o usuário é redirecionado
  /// para a rota correspondente ao seu papel (user, owner, admin).
  ///
  /// Em caso de falha, exibe um AlertDialog informando erro de login.
  Future login(String email, String password) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          context = context;
          return const Loading();
        },
      );

      final response = await httpCliente.post('/login', {
        'email': email,
        'password': password,
      });

      Navigator.pop(context);

      token = response['token'];
      id_user = response['id'];
      role = response['role'];
      await sharedPreferences.setString('id', id_user.toString());
      await sharedPreferences.setString('role', role);
      await sharedPreferences.setString('token', token);

      // Redireciona conforme o papel do usuário
      if (role == 'user') {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else if (role == 'owner') {
        Navigator.pushNamedAndRemoveUntil(context, '/homeOwner', (route) => false);
      } else if (role == 'admin') {
        Navigator.pushNamedAndRemoveUntil(context, '/homeAdm', (route) => false);
      }
    } catch (error) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login Inválido',
                style: TextStyle(
                  color: verde_black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: 'Poppins',
                )),
            content: Text('E-mail ou senha inválidos. Tente novamente.',
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SingleChildScrollView(
        child: Form(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 150,
                ),
                Text(
                  'Bem vindo de volta',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 46, 60, 78),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'Faça login em sua conta',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(255, 46, 60, 78),
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 300,
                  child: Divider(),
                ),
                SizedBox(
                  height: 60,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
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
                      SizedBox(
                        height: 20,
                      ),
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
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      SizedBox(
                        width: 365,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              login(_email.text.trim(), _password.text.trim());
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white),
                            side: MaterialStateProperty.all(const BorderSide(
                              color: Color.fromARGB(255, 24, 157, 130),
                              width: 1.5,
                            )),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                            overlayColor:
                                MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Color.fromARGB(255, 46, 60, 78);
                              }
                              return null;
                            }),
                            elevation: MaterialStateProperty.all(0),
                            minimumSize:
                                MaterialStateProperty.all(const Size(200, 50)),
                          ),
                          child: Text(
                            'Entrar',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Color.fromARGB(255, 24, 157, 130),
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SignUpPrompt(
                        promptText: 'Não tem uma conta? ',
                        actionText: 'Cadastre-se',
                        onSignUpTap: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        )),
      ),
    );
  }
}
