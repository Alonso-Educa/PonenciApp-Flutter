import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/app_state.dart';
import '../models/evento.dart';
import '../widgets/custom_scaffold.dart';
import 'eventos/detalle_evento_page.dart';

// ─────────────────────────────────────────────
// ESTADÍSTICAS
// Muestra un resumen de los eventos y ponencias
// del organizador activo, con acceso rápido a
// los eventos más recientes.
// ─────────────────────────────────────────────

class EstadisticasPage extends StatefulWidget {
  const EstadisticasPage({super.key});

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  bool _cargando = true;
  int _totalEventos = 0;
  int _totalPonencias = 0;
  Evento? _proximoEvento;

  // Lista de los 3 eventos más recientes con su número de ponencias
  List<Map<String, dynamic>> _eventosRecientes = [];

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    try {
      // Carga todos los eventos del organizador
      final eventosSnap = await FirebaseFirestore.instance
          .collection('eventos')
          .where('idOrganizador', isEqualTo: uid)
          .get();

      _totalEventos = eventosSnap.docs.length;

      // Para cada evento cuenta sus ponencias
      int totalPonencias = 0;
      final List<Map<String, dynamic>> eventosConPonencias = [];
      DateTime? fechaProxima;
      Evento? proximoEvento;

      for (final doc in eventosSnap.docs) {
        final evento = Evento(
          idEvento: doc.id,
          nombre: doc.data()['nombre'] ?? '',
          fecha: doc.data()['fecha'] ?? '',
          lugar: doc.data()['lugar'] ?? '',
          descripcion: doc.data()['descripcion'] ?? '',
          codigoEvento: doc.data()['codigoEvento'] ?? '',
        );

        // Cuenta las ponencias de este evento
        final ponenciasSnap = await FirebaseFirestore.instance
            .collection('ponencias')
            .where('idEvento', isEqualTo: doc.id)
            .get();

        final numPonencias = ponenciasSnap.docs.length;
        totalPonencias += numPonencias;

        eventosConPonencias.add({
          'evento': evento,
          'ponencias': numPonencias,
        });

        // Detecta el evento más próximo comparando fechas
        // El formato esperado es dd/MM/yyyy
        try {
          final partes = evento.fecha.split('/');
          if (partes.length == 3) {
            final fechaEvento = DateTime(
              int.parse(partes[2]),
              int.parse(partes[1]),
              int.parse(partes[0]),
            );
            final ahora = DateTime.now();
            if (fechaEvento.isAfter(ahora)) {
              if (fechaProxima == null || fechaEvento.isBefore(fechaProxima)) {
                fechaProxima = fechaEvento;
                proximoEvento = evento;
              }
            }
          }
        } catch (_) {
          // Si el formato de fecha no es parseable simplemente lo ignora
        }
      }

      // Ordena por fecha descendente y toma los 3 más recientes
      eventosConPonencias.sort((a, b) {
        final eventoA = a['evento'] as Evento;
        final eventoB = b['evento'] as Evento;
        return eventoB.fecha.compareTo(eventoA.fecha);
      });

      if (mounted) {
        setState(() {
          _totalPonencias = totalPonencias;
          _proximoEvento = proximoEvento;
          _eventosRecientes = eventosConPonencias.take(3).toList();
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando estadísticas: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final organizador = appState.organizadorActual;
    final theme = Theme.of(context);

    return CustomScaffold(
      title: 'Estadísticas',
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              // Permite recargar los datos deslizando hacia abajo
              onRefresh: _cargarEstadisticas,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [

                  // ── Bienvenida personalizada ──────────────────
                  Text(
                    'Hola, ${organizador?.nombre ?? 'Organizador'} 👋',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Aquí tienes un resumen de tu actividad',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Tarjetas de resumen ───────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _TarjetaResumen(
                          icono: Icons.event,
                          valor: '$_totalEventos',
                          etiqueta: 'Eventos',
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TarjetaResumen(
                          icono: Icons.mic,
                          valor: '$_totalPonencias',
                          etiqueta: 'Ponencias',
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Próximo evento ────────────────────────────
                  _proximoEvento != null
                      ? Card(
                          elevation: 3,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: Icon(
                                Icons.event_available,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            title: const Text(
                              'Próximo evento',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            subtitle: Text(
                              _proximoEvento!.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            trailing: Text(
                              _proximoEvento!.fecha,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetalleEventoPage(
                                  evento: _proximoEvento!,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Card(
                          elevation: 2,
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.event_busy),
                            ),
                            title: const Text('Sin eventos próximos'),
                            subtitle: const Text(
                              'Crea un evento en la sección de Eventos',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),

                  const SizedBox(height: 24),

                  // ── Eventos recientes ─────────────────────────
                  if (_eventosRecientes.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Eventos recientes',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Toca para ver detalle',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...(_eventosRecientes.map((item) {
                      final evento = item['evento'] as Evento;
                      final numPonencias = item['ponencias'] as int;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 2,
                        child: ListTile(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DetalleEventoPage(evento: evento),
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundColor:
                                theme.colorScheme.secondaryContainer,
                            child: Text(
                              evento.nombre.isNotEmpty
                                  ? evento.nombre[0].toUpperCase()
                                  : 'E',
                              style: TextStyle(
                                color: theme.colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            evento.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${evento.fecha} · ${evento.lugar}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Chip(
                            label: Text(
                              '$numPonencias ${numPonencias == 1 ? 'ponencia' : 'ponencias'}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      );
                    })),
                  ] else ...[
                    // Estado vacío
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 32),
                          Icon(
                            Icons.bar_chart,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aún no tienes eventos',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Crea tu primer evento en la sección\nde Eventos y Ponencias',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────
// WIDGET AUXILIAR: TARJETA DE RESUMEN
// Muestra un número grande con icono y etiqueta.
// ─────────────────────────────────────────────

class _TarjetaResumen extends StatelessWidget {
  final IconData icono;
  final String valor;
  final String etiqueta;
  final Color color;

  const _TarjetaResumen({
    required this.icono,
    required this.valor,
    required this.etiqueta,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              valor,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              etiqueta,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}