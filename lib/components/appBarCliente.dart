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
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: true,
      backgroundColor: verde_medio,
      automaticallyImplyLeading: false,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: Image(
            image: AssetImage("assets/images/logo_nova.png"),
            height: 50,
          ),
        ),
      ],
      leading: IconButton(
        icon: const Icon(Icons.logout, color: Colors.white),
        onPressed: () async {
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                'Confirmação',
                style: TextStyle(
                  color: verde_medio,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: 'Poppins',
                ),
              ),
              content: const Text(
                'Deseja realmente sair?',
                style: TextStyle(
                  color: verde_black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Sair',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          );

          if (shouldLogout ?? false) {
            await logout();
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
