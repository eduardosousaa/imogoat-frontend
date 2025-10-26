import 'package:imogoat/models/immobile.dart';
import 'package:imogoat/models/immobile_post.dart';
import 'package:imogoat/models/rest_client.dart';

class ImmobileRepository {
  final RestClient _rest;

  ImmobileRepository({required RestClient restClient}) : _rest = restClient;

  /// Busca todos os imóveis cadastrados no servidor.
  /// Retorna uma lista de objetos [Immobile] convertidos a partir da resposta da API.
  Future<List<Immobile>> buscarImmobiles() async {
    final response = await _rest.get('/immobile');
    return (response as List)
        .map<Immobile>((item) => Immobile.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  /// Cria um novo imóvel no servidor.
  /// Recebe o path da rota e um objeto [ImmobilePost] com os dados do imóvel.
  /// Retorna `true` se a operação for bem-sucedida, ou `false` em caso de erro.
  Future<bool> createImmobile(String path, ImmobilePost data) async {
    try {
      await _rest.post(path, data.toMap());
      return true;
    } catch (error) {
      print('Erro ao criar imóvel: $error');
      return false;
    }
  }

  /// Atualiza um imóvel existente no servidor.
  /// Recebe o path da rota e os novos dados do imóvel através de um ImmobilePost.
  /// Retorna `true` se a atualização for bem-sucedida, ou `false` caso ocorra um erro.
  Future<bool> updateImmobile(String path, ImmobilePost data) async {
    try {
      await _rest.put(path, data.toMap());
      return true;
    } catch (error) {
      print('Erro ao atualizar imóvel: $error');
      return false;
    }
  }

  /// Exclui um imóvel com base no seu immobileId.
  /// Caso ocorra um erro durante a exclusão, ele será impresso no console e relançado.
  Future<void> deleteImmobile(String immobileId) async {
    try {
      await _rest.delete('http://172.31.240.1:5000/delete-immobile', immobileId);
    } catch (error) {
      print('Erro ao deletar imóvel: $error');
      rethrow;
    }
  }

  /// Obtém o ID do último imóvel criado no sistema.
  /// Retorna o maior valor de `id` encontrado na resposta da API,
  /// ou `null` caso não haja imóveis cadastrados ou ocorra um erro.
  Future<int?> getLastCreatedImmobileId() async {
    try {
      final response = await _rest.get('/immobile');

      if (response.isNotEmpty) {
        response.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
        return response[0]['id'];
      }
    } catch (error) {
      print('Erro ao buscar o último imóvel criado: $error');
    }
    return null;
  }
}
