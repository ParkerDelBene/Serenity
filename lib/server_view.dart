import 'package:flutter/material.dart';

class ServerView extends StatelessWidget {
  const ServerView({super.key});

  @override
  Widget build(BuildContext context) {
    MediaQueryData query = MediaQuery.of(context);

    double width = query.size.width;
    double height = query.size.height;

    return Scaffold(
      body: SizedBox(
        width: width,
        height: height,
        child: Row(
          children: [
            SizedBox(
              width: width * .08,
              child: Column(
                children: [
                  Expanded(
                      child: Container(
                    color: Colors.green,
                  ))
                ],
              ),
            ),
            SizedBox(
              width: width * .72,
              child: Column(
                children: [
                  Expanded(
                      child: Container(
                    color: Colors.blue,
                  ))
                ],
              ),
            ),
            SizedBox(
              width: width * .2,
              child: Column(
                children: [
                  Expanded(
                      child: Container(
                    color: Colors.purple,
                  ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
