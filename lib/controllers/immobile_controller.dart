import 'package:flutter/material.dart';
import 'package:imogoat/models/immobile.dart';
import 'package:imogoat/models/immobile_post.dart';
import 'package:imogoat/repositories/immobile_repository.dart';

class ControllerImmobile extends ChangeNotifier {
  final ImmobileRepository _repository;
  bool result = true;
  String search = "";

  var _immobiles = <Immobile>[];
  bool loading = false;
  bool searching = false;

  int? lastCreatedImmobileId;

  /// Atualiza o termo de busca para imóveis e notifica os listeners.
  void changeSearch(String key) {
    search = key;
    notifyListeners();
  }

  /// Alterna o estado de busca (`searching`).
  /// Caso seja desativado, o termo de busca é limpo.
  void changeSearching() {
    searching = !searching;
    if (!searching) search = "";
    notifyListeners();
  }

  ControllerImmobile({required ImmobileRepository immobileRepository})
      : _repository = immobileRepository;

  /// Retorna a lista de imóveis filtrada de acordo com o bairro pesquisado.
  List<Immobile> get immobile {
    return _immobiles
        .where((e) => e.neighborhood.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }

  /// Busca todos os imóveis no repositório.
  /// Define `loading` como verdadeiro durante o processo
  /// e notifica os listeners ao final.
  Future<void> buscarImmobiles() async {
    try {
      loading = true;
      _immobiles = await _repository.buscarImmobiles();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Cria um novo imóvel com os dados fornecidos.
  /// O parâmetro path define o endpoint da requisição,
  /// e data contém as informações do imóvel a ser criado.
  Future<void> createImmobile(String path, ImmobilePost data) async {
    try {
      loading = true;
      notifyListeners();
      await _repository.createImmobile(path, data);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Atualiza um imóvel existente com base no path e nos novos dados.
  /// O parâmetro data contém as informações atualizadas.
  Future<void> updateImmobile(String path, ImmobilePost data) async {
    try {
      loading = true;
      notifyListeners();
      print('Path: $path');
      await _repository.updateImmobile(path, data);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Remove um imóvel do sistema com base em seu immobileId.
  /// Caso ocorra um erro, ele será exibido no console.
  Future<void> deleteImmobile(String immobileId) async {
    try {
      await _repository.deleteImmobile(immobileId);
    } catch (e) {
      print('Erro ao remover o imóvel: $e');
    }
  }

  /// Retorna o ID do último imóvel criado.
  /// Também atualiza o valor de [lastCreatedImmobileId] internamente.
  Future<int?> getLastCreatedImmobileId() async {
    try {
      loading = true;
      notifyListeners();
      lastCreatedImmobileId = await _repository.getLastCreatedImmobileId();
      return lastCreatedImmobileId;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
