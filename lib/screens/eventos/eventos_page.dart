import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/evento.dart';
import '../../widgets/custom_scaffold.dart';
import '../../utils/dialog_crear_evento.dart';
import 'detalle_evento_page.dart';

// ─────────────────────────────────────────────
// EVENTOS PAGE
// Lista todos los eventos del organizador activo
// cargándolos desde Firestore. Permite crear,
// editar y eliminar eventos.
// ─────────────────────────────────────────────

class EventosPage extends StatefulWidget {
  const EventosPage({super.key});

  @override
  State<EventosPage> createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  List<Evento> _eventos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  Future<void> _cargarEventos() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    try {
      final snap = await FirebaseFirestore.instance
          .collection('eventos')
          .where('idOrganizador', isEqualTo: uid)
          .get();

      final eventos = snap.docs.map((doc) {
        return Evento(
          idEvento: doc.id,
          nombre: doc.data()['nombre'] ?? '',
          fecha: doc.data()['fecha'] ?? '',
          lugar: doc.data()['lugar'] ?? '',
          descripcion: doc.data()['descripcion'] ?? '',
          codigoEvento: doc.data()['codigoEvento'] ?? '',
        );
      }).toList();

      // Ordena por fecha descendente
      eventos.sort((a, b) => b.fecha.compareTo(a.fecha));

      if (mounted) {
        setState(() {
          _eventos = eventos;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargando = false);
        _snack('Error cargando eventos: $e');
      }
    }
  }

  void _snack(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _mostrarDialogoEvento(Evento? eventoEditando) {
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
        onGuardar: (evento) {
          if (eventoEditando == null) {
            setState(() => _eventos.insert(0, evento));
          } else {
            setState(() {
              _eventos = _eventos.map((e) {
                return e.idEvento == evento.idEvento ? evento : e;
              }).toList();
            });
          }
        },
      ),
    );
  }

  void _confirmarEliminar(Evento evento) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Eliminar evento'),
        content: Text(
          '¿Deseas eliminar "${evento.nombre}"? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _eliminarEvento(evento);
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

  Future<void> _eliminarEvento(Evento evento) async {
    try {
      // Elimina todas las ponencias del evento primero
      final ponencias = await FirebaseFirestore.instance
          .collection('ponencias')
          .where('idEvento', isEqualTo: evento.idEvento)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in ponencias.docs) {
        batch.delete(doc.reference);
      }
      // Elimina el evento
      batch.delete(
        FirebaseFirestore.instance.collection('eventos').doc(evento.idEvento),
      );
      await batch.commit();

      setState(() {
        _eventos.removeWhere((e) => e.idEvento == evento.idEvento);
      });

      _snack('Evento eliminado correctamente');
    } catch (e) {
      _snack('Error eliminando evento: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScaffold(
      title: 'Eventos',
      fab: FloatingActionButton(
        onPressed: () => _mostrarDialogoEvento(null),
        child: const Icon(Icons.add),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarEventos,
              child: _eventos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.event, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No tienes eventos creados',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Pulsa el botón + para crear uno',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _eventos.length,
                      itemBuilder: (context, index) {
                        final evento = _eventos[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            titleAlignment: ListTileTitleAlignment.center,
                            onTap: () async {
                              // Al volver del detalle recarga por si
                              // hubo cambios en las ponencias
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetalleEventoPage(evento: evento),
                                ),
                              );
                            },
                            title: Text(
                              evento.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${evento.fecha}\n${evento.lugar}'
                              '\nCódigo: ${evento.codigoEvento}',
                            ),
                            isThreeLine: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'editar') {
                                  _mostrarDialogoEvento(evento);
                                } else {
                                  _confirmarEliminar(evento);
                                }
                              },
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  value: 'editar',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Editar'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'eliminar',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Eliminar',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                        ),
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
            ),
    );
  }
}