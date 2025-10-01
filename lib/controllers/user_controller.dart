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

  void changeSearch(String key) {
    search = key;
    notifyListeners();
  }

  void changeSearching() {
    searching = !searching;
    if (!searching) search = "";
    notifyListeners();
  }

  ControllerUser({required UserRepository userRepository})
      : _repository = userRepository;

  List<User> get user {
    return _users
        .where((e) => e.username.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }

  Future<void> buscarUsers() async {
    try {
      loading = true;
      _users = await _repository.buscarUsers();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

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

  Future<void> deleteUser(String id) async {
    try {
      await _repository.deleteUser(id);
    } catch (e) {
      print('Erro ao remover usuário: $e');
    }
  }

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
