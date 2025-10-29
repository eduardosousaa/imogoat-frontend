import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:imogoat/components/buttonHomeSearch.dart';
import 'package:imogoat/controllers/immobile_controller.dart';
import 'package:imogoat/models/immobile.dart';
import 'package:imogoat/models/rest_client.dart';
import 'package:imogoat/repositories/immobile_repository.dart';
import 'package:imogoat/screens/owner/flow/step_one_immobilePage.dart';
import 'package:imogoat/screens/user/immobileDetailPage.dart';
import 'package:imogoat/styles/color_constants.dart';

class MainHomeAdmPage extends StatefulWidget {
  const MainHomeAdmPage({super.key});

  @override
  State<MainHomeAdmPage> createState() => _MainHomeAdmPageState();
}

class _MainHomeAdmPageState extends State<MainHomeAdmPage> {
  final controller = ControllerImmobile(
      immobileRepository: ImmobileRepository(restClient: GetIt.I.get<RestClient>()));
  
  bool _isLoading = true;
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
          title: Text('Confirmar exclusão',
          style: TextStyle(
            color: verde_medio,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Poppins'
          ),),
          content: Text('Tem certeza de que deseja excluir este imóvel?',
          style: TextStyle(
            color: verde_black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'Poppins'
          ),),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('Cancelar',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins'
              ),),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Excluir',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins'
              ),),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      removeImmobile(immobileId);
    }
  }

  /// Realiza uma busca geral por imóveis, atualizando a lista filtrada com
  /// todos os resultados do controller.
  ///
  /// 1. Define o estado de carregamento ([_isLoading]) como `true`.
  /// 2. Chama [controller.buscarImmobiles()] para buscar os dados.
  /// 3. Atualiza [filteredImmobiles] com a lista completa de [controller.immobile].
  /// 4. Define o estado de carregamento como `false`.
  Future<void> _searchImmobiles() async {
    setState(() {
      _isLoading = true;
    });
    await controller.buscarImmobiles();
    setState(() {
      filteredImmobiles = controller.immobile;
      _isLoading = false;
    });
  }

  /// Carrega a lista de imóveis somente se a lista [filteredImmobiles] estiver vazia.
  ///
  /// 1. Se [filteredImmobiles] estiver vazia, chama [controller.buscarImmobiles()]
  ///    e carrega os dados em [filteredImmobiles].
  /// 2. Se a lista já contiver dados, apenas define [_isLoading] como `false`.
  /// 3. Atualiza o estado da UI.
  Future<void> _loadImmobiles() async {
    if (filteredImmobiles.isEmpty) {
      await controller.buscarImmobiles();
      filteredImmobiles = controller.immobile;
      _isLoading = false;
    } else {
      _isLoading = false;
    }
    setState(() {
      _isLoading = false;
    });
  }

  /// Remove um imóvel com base no seu ID e recarrega a lista de imóveis.
  ///
  /// Em caso de sucesso:
  /// 1. Chama [controller.deleteImmobile] para remover o imóvel.
  /// 2. Recarrega a lista de imóveis chamando [_loadImmobiles] para atualizar a UI.
  /// 3. Exibe uma [SnackBar] de sucesso.
  ///
  /// Em caso de erro:
  /// 1. Captura e imprime o erro no console.
  /// 2. Exibe uma [SnackBar] de erro.
  ///
  /// @param immobileId O identificador (ID) único do imóvel a ser removido.
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => StapeOneCreateImmobilePage()));
        }
      ),
      backgroundColor: background,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFF265C5F),
              ),
            )
            : SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        const SizedBox(
                          width: 350,
                          child: Divider(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  cursorColor: Colors.black,
                                  onChanged: (value) {
                                    setState(() {
                                      controller.changeSearch(value);
                                      filteredImmobiles = controller.immobile;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.search),
                                    labelText: 'Digite sua busca',
                                    labelStyle: TextStyle(
                                      color: verde_black,
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              CustomButtonSearch(
                                text: 'Pesquisar', 
                                onPressed: () {
                                  _searchImmobiles();
                                }
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        filteredImmobiles.isEmpty
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
                        : Stack(
                          children: [
                            SizedBox(
                            child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                          builder: (context) => ImmobileDetailPage(immobile: immobile),
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
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            immobile.images.isNotEmpty
                                                ? Image.network(
                                                    immobile.images.first.url,
                                                    height: 100,
                                                    width: MediaQuery.of(context).size.width,
                                                    fit: BoxFit.cover,
                                                  )
                                                : const Text('Imagem indisponível'),
                                            const SizedBox(height: 5),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Flexible(
                                                    child: Text(
                                                      immobile.name,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xFF265C5F),
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                const SizedBox(width: 8),
                                                  IconButton(
                                                    onPressed: () {
                                                      final immobileId = immobile.id;
                                                      print('Id do imóvel: $immobileId');
                                                      confirmDelete(immobileId.toString());
                                                    },
                                                    icon: Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                  )
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.location_on,
                                                  size: 12,
                                                  color: Color(0xFF265C5F),
                                                ),
                                                const SizedBox(width: 4),
                                                Flexible(
                                                    child: Text(
                                                      immobile.neighborhood,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 10,
                                                        color:
                                                            Color(0xFF265C5F),
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
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
                          ]
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