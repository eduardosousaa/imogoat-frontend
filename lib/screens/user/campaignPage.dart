import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:imogoat/controllers/user_controller.dart';
import 'package:imogoat/models/rest_client.dart';
import 'package:imogoat/repositories/user_repository.dart';
import 'package:imogoat/screens/owner/flow/step_one_immobilePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:imogoat/styles/color_constants.dart';

class CampaignPage extends StatefulWidget {
  const CampaignPage({super.key});

  @override
  State<CampaignPage> createState() => _CampaignPageState();
}

class _CampaignPageState extends State<CampaignPage> {
  final controller = ControllerUser(userRepository: UserRepository(restClient: GetIt.I.get<RestClient>()));

  /// Atualiza o papel (role) do usuário logado para 'owner' (proprietário)
  /// e navega para a primeira etapa de criação de imóvel.
  ///
  /// O fluxo de operação é:
  /// 1. Obtém o ID do usuário ([userId]) salvo nas [SharedPreferences].
  /// 2. Chama [controller.updateUser] para enviar a requisição de alteração do papel
  ///    para 'owner' na API.
  /// 3. Em caso de sucesso, navega para a [StapeOneCreateImmobilePage].
  /// 4. Em caso de erro, o erro é impresso no console.
  Future<void> _updateUserType() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userId = sharedPreferences.getString('id').toString();
    try {
      await controller.updateUser('/alter-user/$userId', 'owner');
      Navigator.push(context, MaterialPageRoute(builder: (context) => StapeOneCreateImmobilePage()));
    } catch (error) {
      print('Erro ao buscar Id do usuário: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                ClipRRect(
                  child: Image.asset(
                    width: 250,
                    height: 170,
                    "assets/images/image-anuncio-transparente.png",
                    fit: BoxFit.fill
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Anuncie seu imóvel no ImoGOAT e alcance inquilinos que valorizam seu espaço. A inscrição é simples, rápida e gratuita, e nós conectamos você a quem está procurando o lar ideal. Deixe que o ImoGOAT faça seu imóvel se destacar!',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    color: Color(0xFF2E3C4E),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Gostaria de anunciar um imóvel hoje?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: verde_medio,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SizedBox(
                        width: 166,
                        height: 166,
                        child: ElevatedButton(
                          onPressed: () {
                            _updateUserType();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: Color(0xFF1F7C70),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.home,
                                  size: 40,
                                  color: Colors.black,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Imóvel',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Se você é proprietário',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
