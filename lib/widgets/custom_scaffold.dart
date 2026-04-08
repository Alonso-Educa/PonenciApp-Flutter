import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final FloatingActionButton? fab;

  const CustomScaffold({
    required this.title,
    required this.body,
    this.fab,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: body,
      floatingActionButton: fab,
    );
  }
}