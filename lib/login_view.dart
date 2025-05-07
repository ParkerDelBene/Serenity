import 'package:flutter/material.dart';
import 'package:serenity/globals.dart';
import 'package:serenity/server_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    /*
      Setting the maximum screen size for reference
      throughout the app.
    */
    if (screenHeight == 0 || screenWidth == 0) {
      Size size = MediaQuery.of(context).size;
      screenHeight = size.height;
      screenWidth = size.width;
      setState(() {});
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => ServerView()));
          },
          child: Text('Login Button'),
        )
      ],
    );
  }
}
