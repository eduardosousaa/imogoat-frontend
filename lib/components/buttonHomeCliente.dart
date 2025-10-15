import 'package:flutter/material.dart';

class SubmitButtonHome extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;

  const SubmitButtonHome({
    Key? key,
    required this.texto,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ElevatedButton(
        onPressed: onPressed, 
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
          side: MaterialStateProperty.all(
            const BorderSide(
              color: Color(0xFF265C5F),
              width: 3, // Aumentar a espessura da borda
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
                return const Color.fromARGB(255, 46, 60, 78); // Cor ao pressionar
              }
              return null; // Defer to the widget's default.
            },
          ),
          elevation: MaterialStateProperty.all(0),
          minimumSize: MaterialStateProperty.all(const Size(8, 30)),
        ),
        child: Text(
          texto,
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF265C5F),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
