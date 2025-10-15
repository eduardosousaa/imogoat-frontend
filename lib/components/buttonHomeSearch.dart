import 'package:flutter/material.dart';

class CustomButtonSearch extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButtonSearch({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed, 
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Color(0xFF265C5F)),
        side: MaterialStateProperty.all(
          const BorderSide(
            color:  Color(0xFF265C5F),
            width: 1,
          ),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.white; // Cor ao pressionar
            }
            return null; // Defer to the widget's default.
          },
        ),
        elevation: MaterialStateProperty.all(0),
        minimumSize: MaterialStateProperty.all(const Size(8, 40)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }
}
