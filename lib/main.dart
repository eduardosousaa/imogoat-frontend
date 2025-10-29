import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:imogoat/controllers/dependency_injection.dart';
import 'package:imogoat/models/rest_client.dart';
import 'package:imogoat/repositories/favorite_repository.dart';
import 'package:imogoat/screens/auth/login.dart';
import 'package:imogoat/screens/auth/sign.dart';
import 'package:imogoat/screens/home/home.dart';
import 'package:imogoat/screens/home/homeAdm.dart';
import 'package:imogoat/screens/home/homeOwner.dart';
import 'package:imogoat/screens/home/initialPage.dart';
import 'package:imogoat/screens/owner/flow/step_three_immobile.dart';
import 'package:imogoat/screens/owner/flow/step_two_immobile.dart';
import 'package:provider/provider.dart';
import 'package:imogoat/screens/admin/userPage.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IMO-GOAT',
      initialRoute: '/initial',
      routes: {
        "/": (context) => const LoginPage(),
        "/signup": (context) => const SignUpPage(),
        "/home": (context) => const HomePage(),
        "/homeOwner": (context) => const HomePageOwner(),
        "/homeAdm": (context) => const HomePageAdm(),
        "/initial": (context) => const Initialpage(),
        "/step_two": (context) => const StepTwoCreateImmobilePage(),
        "/step_three": (context) => const StepThreeCreateImmobilePage(),
        "/user_page": (context) => const UserPage(),
      },
    );
  }
}
