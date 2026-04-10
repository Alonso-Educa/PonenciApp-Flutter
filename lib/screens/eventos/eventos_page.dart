import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/evento.dart';
import '../../providers/app_state.dart';
import '../../widgets/custom_scaffold.dart';
import '../../utils/dialog_crear_evento.dart';
import 'detalle_evento_page.dart';

class EventosPage extends StatelessWidget {
  const EventosPage({super.key});

  void _mostrarDialogoEvento(BuildContext context, Evento? eventoEditando) {
    final appState = context.read<MyAppState>();
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (_) => DialogCrearEvento(
        eventoEditando: eventoEditando,
        nombreCtrl: TextEditingController(text: eventoEditando?.nombre ?? ''),
        fechaCtrl: TextEditingController(text: eventoEditando?.fecha ?? ''),
        lugarCtrl: TextEditingController(text: eventoEditando?.lugar ?? ''),
        descripcionCtrl: TextEditingController(
          text: eventoEditando?.descripcion ?? '',
        ),
        onGuardar: (evento) => eventoEditando == null
            ? appState.addEvento(evento)
            : appState.updateEvento(evento),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, Evento evento) {
    final appState = context.read<MyAppState>();
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Eliminar evento'),
        content: Text(
          '¿Deseas eliminar "${evento.nombre}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              appState.deleteEvento(evento.idEvento);
              Navigator.pop(context);
            },
            child: Text(
              'Eliminar',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventos = context.watch<MyAppState>().eventos;

    return CustomScaffold(
      title: 'Eventos',
      fab: FloatingActionButton(
        onPressed: () => _mostrarDialogoEvento(context, null),
        child: const Icon(Icons.add),
      ),
      body: eventos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.event, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes eventos creados',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pulsa el botón + para crear uno',
                    style: TextStyle(fontSize: 12, color: Colors.black38),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: eventos.length,
              itemBuilder: (context, index) {
                final evento = eventos[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    titleAlignment: ListTileTitleAlignment.center,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetalleEventoPage(evento: evento),
                      ),
                    ),
                    title: Text(
                      evento.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${evento.fecha}\n${evento.lugar}'),
                        Text(
                          'Código: ${evento.codigoEvento}',
                          style: TextStyle(color: Color(0xFF475D92)),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'editar') {
                          _mostrarDialogoEvento(context, evento);
                        } else {
                          _confirmarEliminar(context, evento);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'editar',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Color(0xFF475D92)),
                              SizedBox(width: 8),
                              Text(
                                'Editar',
                                style: TextStyle(color: Color(0xFF475D92)),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'eliminar',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              const SizedBox(width: 8),
                              const Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
