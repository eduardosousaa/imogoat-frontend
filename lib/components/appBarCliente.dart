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
          Image(image: AssetImage("assets/images/logo_nova.png"),
          height: 50,
          ),
        ],
        leading: PopupMenuButton(
          color: branco,
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Configurações'),
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Sair'),
                ),
              ),
          ],
          onSelected: (value) {
            if (value == 'logout') {
              logout();
              Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
            } 
            // else if (value == 'settings') {
            //   Navigator.pushNamed(context, '/settings');
            // }
          },
        )
      );
  }
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}