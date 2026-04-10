import 'package:flutter/material.dart';
import '../../models/evento.dart';
import '../../models/ponencia.dart';
import '../../widgets/custom_scaffold.dart';
import '../../utils/dialog_qr.dart';

class DetallePonenciaPage extends StatelessWidget {
  final Ponencia ponencia;
  final Evento evento;

  const DetallePonenciaPage({
    super.key,
    required this.evento,
    required this.ponencia,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScaffold(
      title: ponencia.titulo,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Cabecera: orden + título ────────────────────
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        '${ponencia.orden}',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        ponencia.titulo,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Datos principales ───────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fila(
                          context,
                          icono: Icons.person,
                          etiqueta: 'Ponente',
                          valor: ponencia.ponente,
                        ),
                        const Divider(height: 24),
                        _fila(
                          context,
                          icono: Icons.schedule,
                          etiqueta: 'Horario',
                          valor: '${ponencia.horaInicio} – ${ponencia.horaFin}',
                        ),
                        const Divider(height: 24),
                        _fila(
                          context,
                          icono: Icons.description,
                          etiqueta: 'Descripción',
                          valor: ponencia.descripcion.isEmpty
                              ? 'Sin descripción'
                              : ponencia.descripcion,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── QR de la ponencia ───────────────────────────
                Text(
                  'Código QR',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => showDialog(
                          context: context,
                          useRootNavigator: true,
                          builder: (_) => DialogQR(
                            titulo:
                                'QR — ${evento.nombre} — ${ponencia.titulo}',
                            contenido:
                                'checkin:${evento.idEvento}:${ponencia.idPonencia}',
                          ),
                        ),
                        icon: const Icon(Icons.qr_code),
                        label: const Text('Ver QR de Check-in de la ponencia'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fila(
    BuildContext context, {
    required IconData icono,
    required String etiqueta,
    required String valor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 22, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etiqueta,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(valor, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}
