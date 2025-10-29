import 'package:imogoat/models/favorite.dart';
import 'package:imogoat/models/rest_client.dart';

class FavoriteRepository {
  final RestClient _rest;

  FavoriteRepository({required RestClient restClient}) : _rest = restClient;

  /// Busca a lista de imóveis favoritados por um usuário específico.
  ///
  /// Faz uma requisição GET para o endpoint `/favorites/{userId}` e mapeia
  /// a resposta JSON para uma lista de objetos [Favorite].
  ///
  /// @param userId O ID do usuário cujos favoritos devem ser buscados.
  /// @returns Uma [Future] que resolve para uma [List] de [Favorite].
  Future<List<Favorite>> buscarFavoritos(String userId) async {
    print('Valor de userId eh: $userId');
    final response = await _rest.get('/favorites/$userId');
    print(response);
    return (response as List)
        .map<Favorite>((item) => Favorite.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  /// Adiciona um imóvel à lista de favoritos do usuário.
  ///
  /// Faz uma requisição POST para o [path] fornecido, enviando o ID do usuário
  /// e o ID do imóvel no corpo da requisição.
  ///
  /// @param path O endpoint da API (ex: '/favorites/add').
  /// @param userId O ID do usuário que está favoritando.
  /// @param immobileId O ID do imóvel a ser adicionado aos favoritos.
  /// @returns Uma [Future] que resolve para `true` se a requisição for bem-sucedida,
  ///          ou `false` em caso de erro.
  Future<bool> favoritarImmobile(
      String path, int userId, int immobileId) async {
    try {
      await _rest.post(
        path,
        {
          'userId': userId,
          'immobileId': immobileId
        },
      );
      return true;
    } catch (error) {
      return false;
    }
  }

  /// Remove um registro de favorito da base de dados.
  ///
  /// Faz uma requisição DELETE para remover o favorito, usando o [favoriteId]
  /// como identificador.
  ///
  /// @param favoriteId O ID do registro de favorito a ser excluído.
  /// @throws Exceção se houver falha na comunicação com o [RestClient].
  Future<void> deleteFavorite(String favoriteId) async {
  try {
    await _rest.delete('https://imogoat-backend.onrender.com/delete-favorites', favoriteId);
  } catch (e) {
    print('Erro ao remover favorito: $e');
    rethrow;
  }
}