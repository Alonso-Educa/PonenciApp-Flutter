import 'package:flutter/material.dart';
import '../../models/evento.dart';
import '../../models/ponencia.dart';
import '../../widgets/custom_scaffold.dart';
import '../../utils/dialog_qr.dart';
import '../../utils/dialog_crear_ponencia.dart';
import 'detalle_ponencia_page.dart';

class DetalleEventoPage extends StatefulWidget {
  final Evento evento;

  const DetalleEventoPage({super.key, required this.evento});

  @override
  State<DetalleEventoPage> createState() => _DetalleEventoPageState();
}

class _DetalleEventoPageState extends State<DetalleEventoPage> {
  List<Ponencia> ponencias = [];

  void _crearPonencia() {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (_) => DialogCrearPonencia(
        idEvento: widget.evento.idEvento,
        ordenSiguiente: ponencias.length + 1,
        onGuardar: (nueva) => setState(() {
          ponencias.add(nueva);
          ponencias.sort((a, b) => a.orden.compareTo(b.orden));
        }),
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
        ordenSiguiente: ponencias.length + 1,
        onGuardar: (editada) => setState(() {
          ponencias = ponencias
              .map((p) => p.idPonencia == editada.idPonencia ? editada : p)
              .toList();
        }),
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
            onPressed: () {
              setState(
                () => ponencias.removeWhere(
                  (p) => p.idPonencia == ponencia.idPonencia,
                ),
              );
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
    final evento = widget.evento;

    return CustomScaffold(
      title: evento.nombre,
      fab: FloatingActionButton(
        onPressed: _crearPonencia,
        child: const Icon(Icons.add),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SizedBox(
          height: constraints.maxHeight,
          child: Column(
            children: [
              // Tarjeta del evento
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
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

              // ── Cabecera ponencias ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Ponencias (${ponencias.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── Lista de ponencias ──────────────────────────────
              Expanded(
                child: ponencias.isEmpty
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
                    : ListView.builder(
                        itemCount: ponencias.length,
                        itemBuilder: (context, index) {
                          final p = ponencias[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: ListTile(
                              titleAlignment: ListTileTitleAlignment.center,
                              leading: CircleAvatar(child: Text('${p.orden}')),
                              title: Text(p.titulo),
                              subtitle: Text(
                                '${p.ponente}\n${p.horaInicio} - ${p.horaFin}',
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
                                  const PopupMenuItem(
                                    value: 'editar',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.edit,
                                          color: Color(0xFF475D92),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Editar',
                                          style: TextStyle(
                                            color: Color(0xFF475D92),
                                          ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
