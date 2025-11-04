import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:imogoat/components/buttonHomeCliente.dart';
import 'package:imogoat/components/buttonHomeSearch.dart';
import 'package:imogoat/controllers/favorite_controller.dart';
import 'package:imogoat/controllers/immobile_controller.dart';
import 'package:imogoat/models/immobile.dart';
import 'package:imogoat/models/rest_client.dart';
import 'package:imogoat/repositories/favorite_repository.dart';
import 'package:imogoat/repositories/immobile_repository.dart';
import 'package:imogoat/screens/user/immobileDetailPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:imogoat/styles/color_constants.dart';

class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  final controller = ControllerImmobile(
      immobileRepository:
          ImmobileRepository(restClient: GetIt.I.get<RestClient>()));
  final controllerFavorite = ControllerFavorite(
      favoriteRepository:
          FavoriteRepository(restClient: GetIt.I.get<RestClient>()));

  bool _isLoading = true;
  List<bool> isFavorited = [];
  List<Immobile> filteredImmobiles = [];

  Animation<double> animation = AlwaysStoppedAnimation(0.5);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Orquestra o carregamento inicial dos dados na tela principal.
  ///
  /// Chama sequencialmente [_loadImmobiles] para obter todos os imóveis
  /// e [_loadFavorites] para marcar quais deles são favoritos do usuário.
  Future<void> _loadData() async {
    await _loadImmobiles();
    await _loadFavorites();
  }

  /// Busca a lista completa de imóveis e inicializa o estado de carregamento.
  ///
  /// 1. Define [_isLoading] como `true`.
  /// 2. Chama [controller.buscarImmobiles()] para buscar os dados.
  /// 3. Atualiza [filteredImmobiles] com a lista completa.
  /// 4. Inicializa [isFavorited] com `false` para todos os itens.
  /// 5. Define [_isLoading] como `false`.
  Future<void> _loadImmobiles() async {
    if (filteredImmobiles.isEmpty && !_isLoading) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    await controller.buscarImmobiles();
    filteredImmobiles = controller.immobile;
    isFavorited = List.generate(controller.immobile.length, (index) => false);
    setState(() {
      _isLoading = false;
    });
  }

  /// Carrega a lista de favoritos do usuário logado e atualiza a flag [isFavorited]
  /// para os imóveis exibidos.
  ///
  /// 1. Obtém o ID do usuário ([userId]) nas [SharedPreferences].
  /// 2. Busca os favoritos usando [controllerFavorite.buscarFavoritos].
  /// 3. Itera sobre a lista de imóveis e marca o índice correspondente em [isFavorited]
  ///    como `true` se o imóvel estiver na lista de favoritos.
  Future<void> _loadFavorites() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userId = sharedPreferences.getString('id').toString();
    try {
      print('Peguei o Id: $userId');
      await controllerFavorite.buscarFavoritos(userId.toString());
      for (var i = 0; i < controller.immobile.length; i++) {
        final immobile = controller.immobile[i];
        if (controllerFavorite.favorites
            .any((fav) => fav.immobileId == immobile.id)) {
          setState(() {
            isFavorited[i] = true;
          });
        }
      }
    } catch (error) {
      print('Erro ao carregar favoritos: $error');
    }
  }

  /// Busca todos os imóveis novamente e os define como a lista filtrada.
  ///
  /// Este método é útil para resetar filtros ou após a realização de uma pesquisa genérica.
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

  /// Filtra a lista de imóveis pelo tipo especificado e atualiza a UI.
  ///
  /// 1. Busca todos os imóveis.
  /// 2. Filtra a lista ([controller.immobile]) por imóveis onde [immobile.type]
  ///    corresponde ao [type] fornecido.
  /// 3. Reinicializa [isFavorited] para corresponder ao tamanho da nova lista filtrada.
  ///
  /// @param type O tipo de imóvel a ser filtrado (ex: 'apartamento', 'casa').
  Future<void> _searchImmobilesByType(String type) async {
    setState(() {
      _isLoading = true;
    });

    await controller.buscarImmobiles();

    filteredImmobiles =
        controller.immobile.where((immobile) => immobile.type == type).toList();

    isFavorited = List.generate(filteredImmobiles.length, (index) => false);

    setState(() {
      _isLoading = false;
    });
  }

  /// Adiciona um imóvel à lista de favoritos do usuário logado.
  ///
  /// Obtém o ID do usuário e chama o método de criação no [controllerFavorite].
  ///
  /// @param immobileId O ID do imóvel a ser favoritado.
  Future<void> favorite(String immobileId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userId = sharedPreferences.getString('id').toString();
    try {
      await controllerFavorite.favoritarImmobile(
          '/create-favorites', int.parse(userId), int.parse(immobileId));
    } catch (error) {
      print('Erro ao favoritar o imóvel: $error');
    }
  }

  /// Remove um imóvel da lista de favoritos do usuário logado.
  ///
  /// 1. Busca a lista de favoritos do usuário.
  /// 2. Encontra o ID do registro de favorito ([favoriteId]) correspondente ao [immobileId].
  /// 3. Se encontrado, chama [controllerFavorite.deleteFavorite] com o [favoriteId].
  ///
  /// @param immobileId O ID do imóvel que deve ser removido dos favoritos.
  Future<void> removeFavorite(String immobileId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userId = sharedPreferences.getString('id').toString();

    try {
      await controllerFavorite.buscarFavoritos(userId);

      int? favoriteId;

      for (var fav in controllerFavorite.favorites) {
        if (fav.immobileId.toString() == immobileId) {
          favoriteId = fav.id;
          break;
        }
      }

      if (favoriteId != null) {
        await controllerFavorite.deleteFavorite(favoriteId.toString());
        print('Favorito removido com sucesso!');
      } else {
        print('Nenhum favorito encontrado para este imóvel.');
      }
    } catch (e) {
      print('Erro ao remover o favorito: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: verde_escuro,
            ),
          )
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        child: Image.asset(
                          "assets/images/header.jpeg",
                          fit: BoxFit.cover,
                          opacity: animation,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Encontre facilmente onde ficar!',
                                    style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: TextFormField(
                                            cursorColor: Colors.black,
                                            onChanged: (value) {
                                              setState(() {
                                                controller.changeSearch(value);
                                                filteredImmobiles =
                                                    controller.immobile;
                                              });
                                            },
                                            decoration: const InputDecoration(
                                              prefixIcon: Icon(Icons.search),
                                              labelText: 'Bairro de interesse',
                                              labelStyle: TextStyle(
                                                  color: verde_black,
                                                  fontFamily: 'Poppins',
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500),
                                              contentPadding: EdgeInsets.zero,
                                              filled: true,
                                              fillColor: Colors.transparent,
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                filteredImmobiles.isEmpty
                    ? const Center(
                        child: Text(
                          "Nenhum imóvel encontrado",
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
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isLandscape =
                                    MediaQuery.of(context).orientation ==
                                        Orientation.landscape;
                                int crossAxisCount = isLandscape
                                    ? (constraints.maxWidth ~/ 250)
                                    : 2;
                                double aspectRatio = isLandscape ? 1.2 : 1;

                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: aspectRatio,
                                  ),
                                  itemCount: filteredImmobiles.length,
                                  itemBuilder: (context, index) {
                                    final immobile = filteredImmobiles[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ImmobileDetailPage(
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
                                              Expanded(
                                                child: immobile
                                                        .images.isNotEmpty
                                                    ? Image.network(
                                                        immobile
                                                            .images.first.url,
                                                        width: double.infinity,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : const Center(
                                                        child: Text(
                                                            'Imagem indisponível')),
                                              ),
                                              const SizedBox(height: 5),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
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
                                                      setState(() {
                                                        isFavorited[index] =
                                                            !isFavorited[index];
                                                      });
                                                      final immobileId =
                                                          controller
                                                              .immobile[index]
                                                              .id;

                                                      if (isFavorited[index]) {
                                                        favorite(immobileId
                                                            .toString());
                                                      } else {
                                                        removeFavorite(
                                                            immobileId
                                                                .toString());
                                                      }
                                                    },
                                                    icon: Icon(
                                                      isFavorited[index]
                                                          ? Icons.favorite
                                                          : Icons
                                                              .favorite_border,
                                                      color: isFavorited[index]
                                                          ? Colors.red
                                                          : Colors.grey,
                                                    ),
                                                  ),
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
                                );
                              },
                            ),
                          )
                        ],
                      ),
                SizedBox(
                  height: 40,
                )
              ],
            ),
          );
  }
}
