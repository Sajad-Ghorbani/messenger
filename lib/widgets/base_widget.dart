import 'package:flutter/material.dart';

class BaseWidget extends StatelessWidget {
  const BaseWidget(
      {Key? key, this.appBar, required this.child, this.floatingActionButton})
      : super(key: key);

  final PreferredSizeWidget? appBar;
  final Widget child;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: child,
      ),
    );
  }
}
