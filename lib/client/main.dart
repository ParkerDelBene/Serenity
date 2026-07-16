import 'package:flutter/material.dart';

import 'package:serenity/client/views/pages/loading_screen.dart/loading_screen.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return LoadingScreen();
  }
}
