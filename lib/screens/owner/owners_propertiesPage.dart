import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:imogoat/controllers/immobile_controller.dart';
import 'package:imogoat/models/immobile.dart';
import 'package:imogoat/models/immobile_post.dart';
import 'package:imogoat/models/rest_client.dart';
import 'package:imogoat/repositories/immobile_repository.dart';
import 'package:imogoat/screens/owner/flow/step_one_immobilePage.dart';
import 'package:imogoat/screens/user/immobileDetailPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:imogoat/styles/color_constants.dart';

class OwnersPropertiesPage extends StatefulWidget {
  const OwnersPropertiesPage({super.key});

  @override
  State<OwnersPropertiesPage> createState() => _OwnersPropertiesPageState();
}

class _OwnersPropertiesPageState extends State<OwnersPropertiesPage> {
  final controller = ControllerImmobile(
      immobileRepository:
          ImmobileRepository(restClient: GetIt.I.get<RestClient>()));

  bool isLoading = true;
  List<Immobile> filteredImmobiles = [];

  @override
  void initState() {
    super.initState();
    _loadImmobiles();
  }

  Future<void> confirmDelete(String immobileId) async {
    final confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmar exclusão',
            style: TextStyle(
                color: verde_medio,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: 'Poppins'),
          ),
          content: Text(
            'Tem certeza de que deseja excluir este imóvel?',
            style: TextStyle(
                color: verde_black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'Poppins'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text(
                'Cancelar',
                style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins'),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(
                'Excluir',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins'),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      removeImmobile(immobileId);
    }
  }

  Future<void> _loadImmobiles() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String proprietaryId = sharedPreferences.getString('id').toString();
    print('Id do proprietário: $proprietaryId');

    await controller.buscarImmobiles();
    filteredImmobiles = controller.immobile.where((immobile) {
      return immobile.ownerId.toString() == proprietaryId;
    }).toList();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> removeImmobile(String immobileId) async {
    try {
      await controller.deleteImmobile(immobileId);
      await _loadImmobiles();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Imóvel excluído com sucesso")),
      );
    } catch (error) {
      print('Erro ao remover o imóvel: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao excluir o imóvel")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xFF1F7C70),
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => StapeOneCreateImmobilePage()));
          }),
      backgroundColor: const Color(0xFFF0F2F5),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF265C5F),
              ),
            )
          : filteredImmobiles.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum imóvel encontrado.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        const Text(
                          'Sua lista de imóveis...',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const Text(
                          'Seus imóveis ficam aqui,',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            color: Color(0xFF2E3C4E),
                          ),
                        ),
                        const Text(
                          'para você ver sempre que quiser.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            color: Color(0xFF2E3C4E),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const SizedBox(
                          width: 350,
                          child: Divider(),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: (filteredImmobiles.length / 2).ceil() * 200,
                          width: MediaQuery.of(context).size.width,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1 / 1,
                            ),
                            itemCount: filteredImmobiles.length,
                            itemBuilder: (context, index) {
                              final immobile = filteredImmobiles[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ImmobileDetailPage(
                                          immobile: immobile),
                                    ),
                                  );
                                },
                                child: Card(
                                  color: Colors.white,
                                  elevation: 5.0,
                                  margin: const EdgeInsets.all(7.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        immobile.images.isNotEmpty
                                            ? Image.network(
                                                immobile.images.first.url,
                                                height: 100,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                fit: BoxFit.cover,
                                              )
                                            : const Text('Imagem indisponível'),
                                        const SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                immobile.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Color(0xFF265C5F),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              onPressed: () {
                                                final immobileId = immobile.id;
                                                print(
                                                    'Id do imóvel: $immobileId');
                                                confirmDelete(
                                                    immobileId.toString());
                                              },
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              size: 12,
                                              color: Color(0xFF265C5F),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              immobile.neighborhood,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 10,
                                                color: Color(0xFF265C5F),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        )
                      ],
                    ),
                  ),
                ),
    );
  }
}
