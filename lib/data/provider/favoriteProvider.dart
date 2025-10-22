import 'package:flutter/material.dart';
import 'package:imogoat/models/favorite.dart';
import 'package:imogoat/repositories/favorite_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteRepository favoriteRepository;
  List<Favorite> _favoriteImmobiles = [];
  bool _isLoading = true;

  List<Favorite> get favorites => _favoriteImmobiles;
  bool get isloading => _isLoading;

  FavoriteProvider({required this.favoriteRepository});

  

  Future<void> loadFavorites() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userId = sharedPreferences.getString('id').toString();
    try {
      _isLoading = true;
      notifyListeners();

      _favoriteImmobiles = await favoriteRepository.buscarFavoritos(userId);

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      print('Erro ao carregar favoritos: $error');
      _isLoading = false;
      notifyListeners();
    }
  }

 Future<void> removeFavorite(String immobileId) async {
    try {
      // Tente encontrar o favorito correspondente ao imóvel
      int? favoriteId;
      for (var fav in _favoriteImmobiles) {
        if (fav.immobileId.toString() == immobileId) {
          favoriteId = fav.id;
          break;
        }
      }

      if (favoriteId != null) {
        // Remova o favorito do repositório
        await favoriteRepository.deleteFavorite(favoriteId.toString());
        print('Favorito removido com sucesso!');

        // Atualize a lista localmente
        _favoriteImmobiles.removeWhere((fav) => fav.id == favoriteId);
        notifyListeners();  // Notifique os ouvintes para atualizar a UI
      } else {
        print('Nenhum favorito encontrado para este imóvel.');
      }
    } catch (e) {
      print('Erro ao remover o favorito: $e');
    }
  }
}

