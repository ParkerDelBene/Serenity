import 'package:flutter/material.dart';

class ClickableWidget extends StatelessWidget {
  const ClickableWidget(this.onClickCallback, this.child, {super.key});

  final void Function() onClickCallback;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClickCallback,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: child,
      ),
    );
  }
}
