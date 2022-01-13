import 'package:flutter/material.dart';

class AdjustForm extends StatelessWidget {
  final Widget child;

  const AdjustForm({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        color: Theme.of(context).colorScheme.secondary,
        margin: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
