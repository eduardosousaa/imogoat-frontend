import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class CustomCurvedNavigationBarAdm extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomCurvedNavigationBarAdm({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  _CustomCurvedNavigationBarState createState() => _CustomCurvedNavigationBarState();
}

class _CustomCurvedNavigationBarState extends State<CustomCurvedNavigationBarAdm> {
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      backgroundColor: Color(0xFFF0F2F5),
      color: Color(0xFF1F7C70),
      animationCurve: Curves.easeInOut,
      animationDuration: Duration(milliseconds: 600),
      key: _bottomNavigationKey,
      index: widget.currentIndex,
      items: const <Widget>[
        Icon(Icons.home, size: 30),
        Icon(Icons.person, size: 30),
      ],
      onTap: widget.onTap,
    );
  }

  void setPage(int index) {
    final CurvedNavigationBarState? navBarState = _bottomNavigationKey.currentState;
    navBarState?.setPage(index);
  }
}