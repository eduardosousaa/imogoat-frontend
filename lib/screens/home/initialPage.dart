import 'package:flutter/material.dart';
import 'package:imogoat/screens/auth/login.dart';
import 'package:imogoat/screens/home/home.dart';
import 'package:imogoat/screens/home/homeAdm.dart';
import 'package:imogoat/screens/home/homeOwner.dart';
import 'package:imogoat/styles/color_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Initialpage extends StatefulWidget {
  const Initialpage({super.key});

  @override
  _Initialpage createState() => _Initialpage();
}

class _Initialpage extends State<Initialpage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (duration) {
        verificaUsuario().then(
          (temUsuario) {
            if (temUsuario) {
              getRole().then((role) {
                if (role == 'user') {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
                } else if (role == 'owner') {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HomePageOwner()),
                    (route) => false,
                  );
                } else if (role == 'admin') {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HomePageAdm()),
                    (route) => false,
                  );
                } else {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              });
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Verificando usuário...',
        style: TextStyle(
          color: verde_black,
          fontSize: 20,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold
        ),),
      ),
    );
  }

  Future<bool> verificaUsuario() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');

    return token != null;
  }

  Future<String> getRole() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? role = sharedPreferences.getString('role');
    print('O tipo de usuário eh: $role');
    return role ?? '';
  }
}