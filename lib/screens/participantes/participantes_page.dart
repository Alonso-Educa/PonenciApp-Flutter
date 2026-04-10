import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../widgets/custom_scaffold.dart';

// ─────────────────────────────────────────────
// SECCIÓN 2: LISTA DE PARTICIPANTES
// Muestra en una lista todos los participantes registrados hasta el momento.
// ─────────────────────────────────────────────
class ParticipantesPage extends StatelessWidget {
  const ParticipantesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lista = context.watch<MyAppState>().participantes;

    return CustomScaffold(
      title: 'Participantes',
      body: lista.isEmpty
          ? const Center(
              child: Text(
                'No hay participantes registrados aún.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '${lista.length} participante(s) registrado(s)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                for (final p in lista)
                  Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment
                            .center, // centra verticalmente todo
                        children: [
                          const CircleAvatar(child: Icon(Icons.person)),
                          const SizedBox(width: 16),
                          // Texto principal
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment
                                  .center, // centra verticalmente
                              children: [
                                Text(
                                  '${p.nombre} ${p.apellidos}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${p.emailEduca}\n${p.centro} · ${p.codigoCentro}',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Chip en trailing
                          Chip(label: Text(p.rol)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
