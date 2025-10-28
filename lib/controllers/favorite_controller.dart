import 'package:imogoat/models/favorite.dart';
import 'package:imogoat/repositories/favorite_repository.dart';

class ControllerFavorite {
  final FavoriteRepository favoriteRepository;
  var _favoriteImmobiles = <Favorite>[];


  ControllerFavorite({required this.favoriteRepository});

  /// Adiciona um imóvel à lista de favoritos do usuário.
  ///
  /// Após a adição bem-sucedida pelo repositório, ele chama [buscarFavoritos]
  /// para atualizar a lista localmente.
  ///
  /// @param path O endpoint ou caminho da API para a requisição.
  /// @param userId O ID do usuário que está favoritando o imóvel.
  /// @param immobileId O ID do imóvel a ser favoritado.
  Future<void> favoritarImmobile(
      String path, int userId, int immobileId) async {
    try {
      final success =
          await favoriteRepository.favoritarImmobile(path, userId, immobileId);

      if (success) {
        // Atualiza localmente
        await buscarFavoritos(userId.toString());
        print('Imóvel favoritado com sucesso');
      } else {
        print('Falha ao favoritar o imóvel no servidor');
      }
    } catch (e) {
      print("Erro ao favoritar o imóvel: $e");
    }
  }

  /// Retorna a lista de imóveis favoritos carregada.
  List<Favorite> get favorites {
    return _favoriteImmobiles;
  }

  /// Busca e atualiza a lista de imóveis favoritos de um usuário.
  ///
  /// O resultado da busca do [favoriteRepository] é armazenado na variável
  /// privada [_favoriteImmobiles].
  ///
  /// @param userId O ID do usuário cujos favoritos devem ser buscados.
  Future<void> buscarFavoritos(String userId) async {
    try {
      _favoriteImmobiles = await favoriteRepository.buscarFavoritos(userId);
      print('Quantidade de favoritos: ${_favoriteImmobiles.length}');
      // Log de debug para mostrar as imagens de cada favorito
      _favoriteImmobiles.forEach((fav) {
        print('Imagens para favorito ${fav.id}: ${fav.images}');
      });
    } catch (e) {
      print('Erro ao buscar favoritos: $e');
    }
  }

  /// Remove um item da lista de favoritos com base no seu ID.
  ///
  /// A remoção é feita chamando o [favoriteRepository].
  /// Nota: O chamador deve ser responsável por recarregar a lista
  /// (chamar [buscarFavoritos]) se a UI precisar ser atualizada após o sucesso.
  ///
  /// @param id O ID do registro de favorito a ser excluído.
  Future<void> deleteFavorite(String id) async {
    try {
      await favoriteRepository.deleteFavorite(id);
    } catch (e) {
      print('Erro ao remover o favorito: $e');
    }
  }
}