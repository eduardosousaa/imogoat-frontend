import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:imogoat/controllers/favorite_controller.dart';
import 'package:imogoat/controllers/immobile_controller.dart';
import 'package:imogoat/models/favorite.dart';
import 'package:imogoat/models/rest_client.dart';
import 'package:imogoat/repositories/favorite_repository.dart';
import 'package:imogoat/repositories/immobile_repository.dart';
import 'package:imogoat/screens/user/immobileDetailPage.dart';
import 'package:imogoat/styles/color_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final controller = ControllerImmobile(
      immobileRepository:
          ImmobileRepository(restClient: GetIt.I.get<RestClient>()));
  final controllerFavorite = ControllerFavorite(
      favoriteRepository:
          FavoriteRepository(restClient: GetIt.I.get<RestClient>()));

  bool isLoading = true;
  List<Favorite> favoriteImmobiles = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  /// Carrega a lista de imóveis favoritos do usuário logado.
  ///
  /// 1. Define [isLoading] como `true` e atualiza o estado.
  /// 2. Obtém o ID do usuário ([userId]) nas [SharedPreferences].
  /// 3. Chama [controllerFavorite.buscarFavoritos] para buscar os dados.
  /// 4. Atualiza [favoriteImmobiles] com a lista do controller e define [isLoading] como `false`.
  /// 5. Em caso de erro, define [isLoading] como `false` e loga a falha.
  Future<void> _loadFavorites() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userId = sharedPreferences.getString('id').toString();

    try {
      await controllerFavorite.buscarFavoritos(userId);

      setState(() {
        favoriteImmobiles = controllerFavorite.favorites;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Erro ao carregar favoritos: $e');
    }
  }

  /// Remove um imóvel da lista de favoritos do usuário e atualiza a UI.
  ///
  /// 1. Busca o ID do registro de favorito ([favoriteId]) correspondente ao [immobileId] na lista local.
  /// 2. Se encontrado, chama [controllerFavorite.deleteFavorite] para remover no backend.
  /// 3. Remove o item da lista [favoriteImmobiles] localmente e atualiza a UI.
  /// 4. Em caso de erro, apenas o erro é logado.
  ///
  /// @param immobileId O ID do imóvel que deve ser removido dos favoritos.
  Future<void> removeFavorite(String immobileId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userId = sharedPreferences.getString('id').toString();

    try {
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
        setState(() {
          favoriteImmobiles
              .removeWhere((fav) => fav.immobileId.toString() == immobileId);
        });
      } else {
        print('Nenhum favorito encontrado para este imóvel.');
      }
    } catch (e) {
      print('Erro ao remover o favorito: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F2F5),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: const Color(0xFF265C5F),
            ))
          : favoriteImmobiles.isEmpty
              ? Center(
                  child: Text(
                  'Nenhum imóvel favoritado.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ))
              : SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        const Text(
                          'Sua lista de favoritos...',
                          style: TextStyle(
                            fontFamily: 'Poppind',
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const Text(
                          'Seus imóveis favoritos ficam aqui,',
                          style: TextStyle(
                            fontFamily: 'Poppind',
                            fontSize: 20,
                            color: Color.fromARGB(255, 46, 60, 78),
                          ),
                        ),
                        const Text(
                          'para você ver sempre que quiser.',
                          style: TextStyle(
                            fontFamily: 'Poppind',
                            fontSize: 20,
                            color: Color.fromARGB(255, 46, 60, 78),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const SizedBox(width: 350, child: Divider()),
                        const SizedBox(height: 20),
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                            childAspectRatio: 0.9 / 1,
                          ),
                          itemCount: favoriteImmobiles.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final favorite = favoriteImmobiles[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImmobileDetailPage(
                                        immobile: favorite.immobile),
                                  ),
                                );
                              },
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                color: Colors.white,
                                elevation: 5.0,
                                margin: const EdgeInsets.all(10.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 3,
                                        child: favorite.images.isNotEmpty
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                child: Image.network(
                                                  favorite.images.first.url,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : const Center(
                                                child: Text(
                                                  'Imagem indisponível',
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                              ),
                                      ),
                                      const SizedBox(height: 2),
                                      Expanded(
                                        flex: 1,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                favorite.immobile.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: Color(0xFF265C5F),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              icon: const Icon(Icons.favorite,
                                                  color: Colors.red, size: 25),
                                              onPressed: () async {
                                                await removeFavorite(favorite
                                                    .immobile.id
                                                    .toString());
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.apartment,
                                              size: 12,
                                              color: Color(0xFF265C5F)),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              favorite.immobile.type,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 10,
                                                color: Color(0xFF265C5F),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
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
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
    );
  }
}
