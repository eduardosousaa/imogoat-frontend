import 'package:flutter/material.dart';
import 'package:imogoat/models/user.dart';
import 'package:imogoat/repositories/user_repository.dart';

class ControllerUser extends ChangeNotifier {
  final UserRepository _repository;
  bool result = false;
  String search = "";

  var _users = <User>[];
  bool loading = false;
  bool searching = false;

  /// Atualiza o termo de busca dos usuários e notifica os listeners.
  void changeSearch(String key) {
    search = key;
    notifyListeners();
  }

  /// Alterna o estado de busca (`searching`) e limpa o termo de busca caso ela seja desativada.
  void changeSearching() {
    searching = !searching;
    if (!searching) search = "";
    notifyListeners();
  }

  ControllerUser({required UserRepository userRepository})
      : _repository = userRepository;

  /// Retorna a lista de usuários filtrada de acordo com o termo de busca.
  List<User> get user {
    return _users
        .where((e) => e.username.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }

  /// Busca a lista de usuários no repositório.
  /// Define `loading` como verdadeiro durante a requisição e notifica os listeners ao final.
  Future<void> buscarUsers() async {
    try {
      loading = true;
      _users = await _repository.buscarUsers();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Realiza o login do usuário com email e password.
  /// Retorna `true` se o login for bem-sucedido.
  Future<bool> login(String path, String email, String password) async {
    try {
      loading = true;
      notifyListeners();
      result = await _repository.loginUser(path, email, password);
    } finally {
      loading = false;
      notifyListeners();
      return result;
    }
  }

  /// Cria um novo usuário com os dados fornecidos.
  /// Retorna `true` se o cadastro for concluído com sucesso.
  Future<bool> signUpUser(String path, String username, String email,
      String password, String phoneNumber, String role) async {
    try {
      loading = true;
      notifyListeners();
      result = await _repository.signUpUser(
          path, username, email, password, phoneNumber, role);
    } finally {
      loading = false;
      notifyListeners();
      return result;
    }
  }

  /// Remove um usuário do sistema com base em seu id.
  /// Caso ocorra um erro, ele será impresso no console.
  Future<void> deleteUser(String id) async {
    try {
      await _repository.deleteUser(id);
    } catch (e) {
      print('Erro ao remover usuário: $e');
    }
  }

  /// Atualiza os dados de um usuário existente.
  /// Recebe o path da requisição e um objeto User com os novos dados.
  /// Retorna `true` se a atualização for bem-sucedida.
  Future<bool> updateUserDate(String path, User data) async {
    try {
      loading = true;
      notifyListeners();
      result = await _repository.updateUserData(path, data);
      print('Result - $result');
    } finally {
      loading = false;
      notifyListeners();
      return result;
    }
  }
}
