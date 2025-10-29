import 'package:flutter/material.dart';
import 'package:imogoat/styles/color_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBarCliente extends StatelessWidget implements PreferredSizeWidget {
  Future<void> logout() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      centerTitle: true,
      backgroundColor: verde_medio,
      automaticallyImplyLeading: false,
      actions: [
        Image(
          image: AssetImage("assets/images/logo_nova.png"),
          height: 50,
        ),
      ],
      leading: IconButton(
        icon: const Icon(Icons.logout, color: Colors.white), // ícone de logout
        onPressed: () async {
          // Mostra o diálogo de confirmação
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              iconColor: Colors.black,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.black,
              title: const Text('Confirmação'),
              content: const Text('Deseja realmente sair?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // não sair
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(true), // confirmar logout
                  child: const Text('Sair'),
                ),
              ],
            ),
          );

          // Se confirmou, executa logout
          if (shouldLogout ?? false) {
            logout(); // sua função de logout
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (Route<dynamic> route) => false,
            );
          }
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
