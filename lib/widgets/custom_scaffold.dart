import 'package:flutter/material.dart';
import 'icono_usuario.dart';

// ─────────────────────────────────────────────
// SCAFFOLD GLOBAL DE LA APLICACIÓN
// Gestiona el scaffold que se ve en todas las ventanas
// ─────────────────────────────────────────────
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
      appBar: AppBar(
        title: Text(title),
        // ── Icono de usuario en todas las pantallas ──────────
        actions: const [IconoUsuario()],
      ),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: body,
      floatingActionButton: fab,
      bottomNavigationBar: Container(
        height: 28,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        alignment: Alignment.center,
        child: Text('PonenciApp - Panel de Organizador', style: const TextStyle(fontSize: 12, color: Colors.white)),
      ),
    );
  }
}