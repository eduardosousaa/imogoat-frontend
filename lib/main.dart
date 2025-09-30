import 'package:flutter/material.dart';
import 'package:imogoat/screens/auth/login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IMO-GOAT',
      initialRoute: '/',
      routes: {
        "/": (context) => const LoginPage(),
      },
    );
  }
}

