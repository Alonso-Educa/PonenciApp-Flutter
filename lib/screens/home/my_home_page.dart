import 'package:flutter/material.dart';
import '../../screens/home/menu_principal.dart';
import '../../screens/participantes/crear_participante.dart';
import '../../screens/participantes/participantes_page.dart';
import '../../screens/eventos/eventos_page.dart';

// ─────────────────────────────────────────────
// PÁGINA PRINCIPAL CON MENÚ LATERAL
// Gestiona la navegación entre las distintas secciones
// mediante un NavigationRail adaptable al ancho de pantalla.
// ─────────────────────────────────────────────
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const MenuPrincipal(),
      const CrearParticipante(),
      const ParticipantesPage(),
      const EventosPage(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 700,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Menú Principal'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_add),
                      label: Text('Crear Participante'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.people),
                      label: Text('Participantes'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.event),
                      label: Text('Eventos y Ponencias'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() => selectedIndex = value);
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: pages[selectedIndex],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}