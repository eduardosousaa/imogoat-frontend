import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:imogoat/styles/color_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F2F5),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                SizedBox(height: 40),
                // Removido Positioned.fill
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                      8.0), // Para um pouco de arredondamento
                  child: Image.asset(
                    "assets/images/logo-fundo-branco-removido.png",
                    width: 250,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'versão 1.0.0',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'O nosso aplicativo de aluguel de imóveis é uma plataforma completa e eficiente para facilitar o processo de busca e locação de imóveis para inquilinos. Nossa plataforma torna o processo de aluguel mais fácil e eficiente para os inquilinos, proporcionando uma experiência fluida e direta.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 300,
                  child: Divider(),
                ),
                SizedBox(height: 60),
                SizedBox(
                  width: 365,
                  child: ElevatedButton(
                    onPressed: () async {
                      final Uri url = Uri.parse(
                          "https://wa.me/558994721317?text=Olá! Obrigado por entrar em contato com o ImoGoat!");

                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    },
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
                      minimumSize:
                          MaterialStateProperty.all(const Size(200, 50)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(FontAwesomeIcons.whatsapp, color: verde_contato),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          'Entrar em contato',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: verde_contato,
                            fontSize: 18,
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
    );
  }
}
