import 'package:imogoat/models/rest_client.dart';
import 'package:imogoat/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  final RestClient _rest;

  UserRepository({required RestClient restClient}) : _rest = restClient;

  /// Realiza a busca de usuários através da rota `user`.
  /// Retorna uma lista de objetos User a partir da resposta da API.
  Future<List<User>> searchUser() async {
    final response = await _rest.get('user');
    return response["groups"].map<User>(User.fromMap).toList();
  }

  /// Busca todos os usuários cadastrados no sistema.
  /// Retorna uma lista de User convertidos a partir da resposta da API.
  Future<List<User>> buscarUsers() async {
    final response = await _rest.get('/user');
    return (response as List)
        .map<User>((item) => User.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  /// Realiza o login de um usuário utilizando email e password.
  /// Em caso de sucesso, armazena o `token`, o `id` e o `role` do usuário
  /// no SharedPreferences para autenticação persistente.
  /// Retorna `true` se o login for bem-sucedido, ou `false` se falhar.
  Future<bool> loginUser(String path, String email, String password) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token;
    int id_user = 0;
    String role = '';

    try {
      final response = await _rest.post(path, {
        'email': email,
        'password': password,
      });
      token = response['token'];
      id_user = response['id'];
      role = response['role'];

      await sharedPreferences.setString('id', id_user.toString());
      await sharedPreferences.setString('role', role);
      await sharedPreferences.setString('token', token);

      return true;
    } catch (error) {
      return false;
    }
  }

  /// Cria um novo usuário no sistema com os dados fornecidos.
  /// Recebe os parâmetros username, email, password, phoneNumber e role.
  /// Retorna `true` se o cadastro for realizado com sucesso.
  Future<bool> signUpUser(
    String path,
    String username,
    String email,
    String password,
    String phoneNumber,
    String role,
  ) async {
    try {
      await _rest.post(path, {
        "username": username,
        "email": email,
        "password": password,
        "phoneNumber": phoneNumber,
        "role": role,
      });

      return true;
    } catch (error) {
      print("Erro ao criar usuário: $error");
      return false;
    }
  }

  /// Exclui um usuário com base no seu id.
  /// Caso ocorra um erro, ele será impresso no console e relançado.
  Future<void> deleteUser(String id) async {
    try {
      await _rest.delete('http://192.168.1.3:5002/delete-user', id);
    } catch (error) {
      print('Erro ao deletar usuário: $error');
      rethrow;
    }
  }

  /// Atualiza os dados de um usuário existente.
  /// Recebe o path da requisição e o objeto User contendo as novas informações.
  /// Retorna `true` se a atualização for bem-sucedida, ou `false` em caso de erro.
  Future<bool> updateUserData(String path, User data) async {
    try {
      await _rest.put(path, data.toMap());
      return true;
    } catch (error) {
      print("Erro ao atualizar usuário: $error");
      return false;
    }
  }

  /// Atualiza o papel ([role]) de um usuário.
  ///
  /// Retorna `true` se a atualização for bem-sucedida.
  Future<bool> updateUser(String path, String role) async {
    try {
      await _rest.put(path, {"role": role});
      return true;
    } catch (error) {
      print("Erro ao atualizar usuário: $error");
      return false;
    }
  }
}
