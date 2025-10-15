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

  void changeSearch(String key) {
    search = key;
    notifyListeners();
  }

  void changeSearching() {
    searching = !searching;
    if (!searching) search = "";
    notifyListeners();
  }

  ControllerImmobile({required ImmobileRepository immobileRepository}) : _repository = immobileRepository;

  List<Immobile> get immobile {
    return _immobiles
        .where((e) => e.neighborhood.toLowerCase().contains(search.toLowerCase())).toList();
  }

  Future<void> buscarImmobiles() async {
    try {
      loading = true;
      _immobiles = await _repository.buscarImmobiles();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

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

  Future<void> deleteImmobile(String immobileId) async {
    try {
      await _repository.deleteImmobile(immobileId);
    } catch (e) {
      print('Erro ao remover o imóvel: $e');
    }
  }

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