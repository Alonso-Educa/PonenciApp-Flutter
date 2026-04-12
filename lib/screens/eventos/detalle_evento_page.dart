import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/evento.dart';
import '../../models/ponencia.dart';
import '../../widgets/custom_scaffold.dart';
import '../../utils/dialog_qr.dart';
import '../../utils/dialog_crear_ponencia.dart';
import 'detalle_ponencia_page.dart';

// ─────────────────────────────────────────────
// DETALLE DE EVENTO
// Carga las ponencias del evento desde Firestore
// y permite crearlas, editarlas y eliminarlas.
// ─────────────────────────────────────────────

class DetalleEventoPage extends StatefulWidget {
  final Evento evento;

  const DetalleEventoPage({super.key, required this.evento});

  @override
  State<DetalleEventoPage> createState() => _DetalleEventoPageState();
}

class _DetalleEventoPageState extends State<DetalleEventoPage> {
  List<Ponencia> _ponencias = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPonencias();
  }

  Future<void> _cargarPonencias() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('ponencias')
          .where('idEvento', isEqualTo: widget.evento.idEvento)
          .get();

      final ponencias = snap.docs.map((doc) {
        return Ponencia(
          idPonencia: doc.id,
          titulo: doc.data()['titulo'] ?? '',
          ponente: doc.data()['ponente'] ?? '',
          descripcion: doc.data()['descripcion'] ?? '',
          horaInicio: doc.data()['horaInicio'] ?? '',
          horaFin: doc.data()['horaFin'] ?? '',
          qrCode: doc.data()['qrCode'] ?? '',
          idEvento: widget.evento.idEvento,
          orden: (doc.data()['orden'] as num?)?.toInt() ?? 0,
        );
      }).toList();

      ponencias.sort((a, b) => a.orden.compareTo(b.orden));

      if (mounted) {
        setState(() {
          _ponencias = ponencias;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargando = false);
        _snack('Error cargando ponencias: $e');
      }
    }
  }

  void _snack(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _crearPonencia() {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (_) => DialogCrearPonencia(
        idEvento: widget.evento.idEvento,
        ordenSiguiente: _ponencias.length + 1,
        onGuardar: (nueva) {
          setState(() {
            _ponencias.add(nueva);
            _ponencias.sort((a, b) => a.orden.compareTo(b.orden));
          });
        },
      ),
    );
  }

  void _editarPonencia(Ponencia ponencia) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (_) => DialogCrearPonencia(
        ponenciaEditando: ponencia,
        idEvento: widget.evento.idEvento,
        ordenSiguiente: _ponencias.length + 1,
        onGuardar: (editada) {
          setState(() {
            _ponencias = _ponencias.map((p) {
              return p.idPonencia == editada.idPonencia ? editada : p;
            }).toList();
          });
        },
      ),
    );
  }

  void _eliminarPonencia(Ponencia ponencia) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Eliminar ponencia'),
        content: Text('¿Deseas eliminar "${ponencia.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _borrarPonencia(ponencia);
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

  Future<void> _borrarPonencia(Ponencia ponencia) async {
    try {
      await FirebaseFirestore.instance
          .collection('ponencias')
          .doc(ponencia.idPonencia)
          .delete();

      setState(() {
        _ponencias.removeWhere((p) => p.idPonencia == ponencia.idPonencia);
      });

      _snack('Ponencia eliminada');
    } catch (e) {
      _snack('Error eliminando ponencia: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final evento = widget.evento;
    final theme = Theme.of(context);

    return CustomScaffold(
      title: evento.nombre,
      fab: FloatingActionButton(
        onPressed: _crearPonencia,
        child: const Icon(Icons.add),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) => SizedBox(
                height: constraints.maxHeight,
                child: Column(
                  children: [
                    // ── Tarjeta del evento ──────────────────────
                    Card(
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              evento.nombre,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16),
                                const SizedBox(width: 6),
                                Text(evento.fecha),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16),
                                const SizedBox(width: 6),
                                Text(evento.lugar),
                              ],
                            ),
                            if (evento.descripcion.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(evento.descripcion),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              'Código: ${evento.codigoEvento}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => showDialog(
                                  context: context,
                                  useRootNavigator: true,
                                  builder: (_) => DialogQR(
                                    titulo: 'QR Check-in — ${evento.nombre}',
                                    contenido: 'checkin:${evento.idEvento}',
                                  ),
                                ),
                                icon: const Icon(Icons.qr_code),
                                label: const Text('Ver QR de Check-in'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Cabecera ponencias ──────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Ponencias (${_ponencias.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Lista de ponencias ──────────────────────
                    Expanded(
                      child: _ponencias.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_note,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'No hay ponencias todavía',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Pulsa el botón + para añadir una',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black38,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _cargarPonencias,
                              child: ListView.builder(
                                itemCount: _ponencias.length,
                                itemBuilder: (context, index) {
                                  final p = _ponencias[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    child: ListTile(
                                      titleAlignment:
                                          ListTileTitleAlignment.center,
                                      leading: CircleAvatar(
                                        child: Text('${p.orden}'),
                                      ),
                                      title: Text(p.titulo),
                                      subtitle: Text(
                                        '${p.ponente}\n'
                                        '${p.horaInicio} - ${p.horaFin}',
                                      ),
                                      isThreeLine: true,
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DetallePonenciaPage(
                                            evento: evento,
                                            ponencia: p,
                                          ),
                                        ),
                                      ),
                                      trailing: PopupMenuButton<String>(
                                        onSelected: (value) {
                                          if (value == 'editar') {
                                            _editarPonencia(p);
                                          } else {
                                            _eliminarPonencia(p);
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
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
