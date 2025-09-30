import 'package:flutter/material.dart';

class SignUpPrompt extends StatelessWidget {
  final VoidCallback onSignUpTap;
  final String promptText;
  final String actionText;

  const SignUpPrompt({
    Key? key,
    required this.onSignUpTap,
    required this.promptText,
    required this.actionText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          promptText,
          style: TextStyle(
            color: Color.fromARGB(255, 46, 60, 78),
          ),
        ),
        InkWell(
          onTap: onSignUpTap,
          child: Text(
            actionText,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Color.fromARGB(225, 24, 157, 130),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}