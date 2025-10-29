import 'package:flutter/material.dart';
import 'package:imogoat/components/appBarCliente.dart';
import 'package:imogoat/components/navigationBarOwner.dart';
import 'package:imogoat/screens/home/mainHome.dart';
import 'package:imogoat/screens/owner/owners_propertiesPage.dart';
import 'package:imogoat/screens/user/campaignPage.dart';
import 'package:imogoat/screens/user/contactsPage.dart';
import 'package:imogoat/screens/user/favoritePage.dart';

class HomePageOwner extends StatefulWidget {
  const HomePageOwner({super.key});

  @override
  State<HomePageOwner> createState() => _HomePageState();
}

class _HomePageState extends State<HomePageOwner> {
  int _page = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        appBar: AppBarCliente(),
        bottomNavigationBar: CustomCurvedNavigationBarOwner(
          currentIndex: _page,
          onTap: (index) {
            _pageController.jumpToPage(index);
          },
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _page = index;
            });
          },
          scrollDirection: Axis.horizontal,
          children: [
            MainHome(),
            FavoritePage(),
            OwnersPropertiesPage(),
            CampaignPage(),
            ContactsPage(),
          ],
        ));
  }
}