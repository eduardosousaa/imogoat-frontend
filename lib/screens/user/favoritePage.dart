import 'package:flutter/material.dart';
import 'package:imogoat/data/provider/favoriteProvider.dart';
import 'package:imogoat/screens/user/immobileDetailPage.dart';
import 'package:imogoat/styles/color_constants.dart';
import 'package:provider/provider.dart';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  void initState() {
    super.initState();
    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
    favoriteProvider.loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favoriteProvider, child) {
        // Exibe o loading somente se estiver carregando e a lista estiver vazia
        if (favoriteProvider.isloading && favoriteProvider.favorites.isEmpty) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF265C5F),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: background,
          body: favoriteProvider.favorites.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum imóvel favoritado.',
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
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1 / 1,
                          ),
                          itemCount: favoriteProvider.favorites.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final favorite = favoriteProvider.favorites[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ImmobileDetailPage(immobile: favorite.immobile),
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
                                      favorite.images.isNotEmpty
                                          ? Image.network(
                                              favorite.images.first.url,
                                              height: 100,
                                              width: MediaQuery.of(context).size.width,
                                              fit: BoxFit.cover,
                                            )
                                          : const Text('Imagem indisponível'),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              favorite.immobile.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                                color: Color(0xFF265C5F),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.favorite, color: Colors.red),
                                            onPressed: () {
                                              print('Id para remover: ${favorite.immobile.id.toString()}');
                                              favoriteProvider.removeFavorite(favorite.immobile.id.toString());
                                            },
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.apartment,
                                            size: 12,
                                            color: Color(0xFF265C5F),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            favorite.immobile.type,
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
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
