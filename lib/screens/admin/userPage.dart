import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:imogoat/components/buttonHomeSearch.dart';
import 'package:imogoat/controllers/user_controller.dart';
import 'package:imogoat/models/rest_client.dart';
import 'package:imogoat/models/user.dart';
import 'package:imogoat/repositories/user_repository.dart';
import 'package:imogoat/screens/admin/createUser.dart';
import 'package:imogoat/screens/admin/userDetailPage.dart';
import 'package:imogoat/styles/color_constants.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final controller = ControllerUser(
      userRepository: UserRepository(restClient: GetIt.I.get<RestClient>()));

  @override
  void initState() {
    controller.buscarUsers();
    super.initState();
  }

  Future<void> _searchUsers() async {
    controller.buscarUsers();
  }

  void _confirmDelete(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmação de Exclusão',
          style: TextStyle(
            color: verde_black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Poppins',
          )),
          content: Text('Deseja excluir o usuário ${user.username}?',
          style: TextStyle(
            color: verde_medio,
            fontWeight: FontWeight.normal,
            fontSize: 16,
            fontFamily: 'Poppins',
          )),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar', 
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins'
              ),),
            ),
            TextButton(
              onPressed: () {
                removeUser(user.id.toString());
                Navigator.of(context).pop();
              },
              child: const Text('Excluir', 
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins'
              ),),
            ),
          ],
        );
      },
    );
  }

  /// Remove um usuário com base no seu ID e atualiza a lista de usuários na UI.
  ///
  /// Em caso de sucesso:
  /// 1. Chama [controller.deleteUser] para remover o usuário no backend.
  /// 2. Chama [_searchUsers] para recarregar e atualizar a lista exibida.
  ///
  /// Em caso de erro:
  /// 1. Captura e imprime o erro no console.
  /// 2. Exibe uma [SnackBar] para notificar o usuário da falha na exclusão.
  ///
  /// @param id O identificador (ID) único do usuário a ser removido.
  Future<void> removeUser(String id) async {
    try {
      await controller.deleteUser(id);
      await _searchUsers();
    } catch (error) {
      print('Erro ao remover o usuário: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao excluir usuário")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        if (controller.loading && controller.user.isEmpty) {
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
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  width: 350,
                  child: Divider(),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: TextFormField(
                          cursorColor: Colors.black,
                          onChanged: (value) {
                            setState(() {
                              controller.changeSearch(value);
                            });
                          },
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            labelText: 'Digite sua busca',
                            labelStyle: TextStyle(
                              color: Color(0xFF2E3C4E),
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor: Colors.transparent,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CustomButtonSearch(text: 'Pesquisar', onPressed: _searchUsers)
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: controller.user.isEmpty
                      ? const Center(child: Text('Nenhum usuário encontrado.', 
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),))
                      : _Body(user: controller.user, onDelete: _confirmDelete),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: verde_medio,
            foregroundColor: Colors.white,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CreateUserPage()));
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  final List<User> user;
  final Function(BuildContext, User) onDelete;

  const _Body({required this.user, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: user.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailPage(user: user[index]),
            ),
          ),
          child: Card(
            elevation: 5.0,
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      user[index].username,
                      style: const TextStyle(color: Colors.white),
                    ),
                    tileColor: verde_escuro,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text(user[index].email),
                        ),
                      ),
                      IconButton(
                        onPressed: () => onDelete(context, user[index]),
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
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
    );
  }
}