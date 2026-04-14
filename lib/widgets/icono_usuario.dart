import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

// ─────────────────────────────────────────────
// ICONO DE USUARIO inicial del nombre si no.
// Al pulsarlo abre una tarjeta con los datos del organizador.
// Se usa en el AppBar de CustomScaffold.
// ─────────────────────────────────────────────

class IconoUsuario extends StatefulWidget {
  const IconoUsuario({super.key});

  @override
  State<IconoUsuario> createState() => _IconoUsuarioState();
}

class _IconoUsuarioState extends State<IconoUsuario> {
  bool _mostrarDialog = false;

  @override
  Widget build(BuildContext context) {
    final organizador = context.watch<MyAppState>().organizadorActual;
    if (organizador == null) return const SizedBox.shrink();

    final inicial = organizador.nombre.isNotEmpty
        ? organizador.nombre[0].toUpperCase()
        : 'O';
    final theme = Theme.of(context);
    final tieneFoto =
        organizador.fotoPerfilUrl != '' &&
        organizador.fotoPerfilUrl.trim().isNotEmpty;
        final tieneFoto2 =
    organizador.fotoPerfilUrl?.trim().isNotEmpty == true;

    print('URL FOTO: ${organizador.fotoPerfilUrl}');
    print('TIENE FOTO: $tieneFoto2');

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => setState(() => _mostrarDialog = true),
        child: Stack(
          children: [
            // ── Avatar ──────────────────────────────────────
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.tertiary,
              foregroundImage: tieneFoto
                  ? NetworkImage(organizador.fotoPerfilUrl.trim())
                  : null,
              child: !tieneFoto
                  ? Text(
                      inicial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    )
                  : null,
            ),

            // ── Dialog de tarjeta de usuario ─────────────────
            if (_mostrarDialog)
              Positioned.fill(
                child: Builder(
                  builder: (ctx) {
                    // Usamos addPostFrameCallback para abrir el dialog
                    // después del build, evitando errores de contexto
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_mostrarDialog) {
                        showDialog(
                          context: context,
                          useRootNavigator: true,
                          builder: (_) => _TarjetaUsuario(
                            inicial: inicial,
                            tieneFoto: tieneFoto,
                            fotoUrl: organizador.fotoPerfilUrl,
                            nombre:
                                '${organizador.nombre} ${organizador.apellidos}',
                            email: organizador.emailEduca,
                            centro:
                                '${organizador.centro} — ${organizador.codigoCentro}',
                            rol:
                                organizador.rol[0].toUpperCase() +
                                organizador.rol.substring(1),
                          ),
                        ).then((_) {
                          if (mounted) {
                            setState(() => _mostrarDialog = false);
                          }
                        });
                      }
                    });
                    return const SizedBox.shrink();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TARJETA DE USUARIO
// Dialog con los datos del organizador activo.
// ─────────────────────────────────────────────

class _TarjetaUsuario extends StatelessWidget {
  final String inicial;
  final bool tieneFoto;
  final String? fotoUrl;
  final String nombre;
  final String email;
  final String centro;
  final String rol;

  const _TarjetaUsuario({
    required this.inicial,
    required this.tieneFoto,
    required this.fotoUrl,
    required this.nombre,
    required this.email,
    required this.centro,
    required this.rol,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(24),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Avatar grande ──────────────────────────────────
            CircleAvatar(
              radius: 36,
              backgroundColor: theme.colorScheme.tertiary,
              backgroundImage: tieneFoto ? NetworkImage(fotoUrl!.trim()) : null,
              child: tieneFoto
                  ? null
                  : Text(
                      inicial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // ── Nombre ─────────────────────────────────────────
            Text(
              nombre,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // ── Rol ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                rol,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // ── Email ──────────────────────────────────────────
            _fila(context, icono: Icons.email_outlined, texto: email),
            const SizedBox(height: 8),

            // ── Centro ─────────────────────────────────────────
            _fila(context, icono: Icons.school_outlined, texto: centro),
            const SizedBox(height: 20),

            // ── Botón cerrar ───────────────────────────────────
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fila(
    BuildContext context, {
    required IconData icono,
    required String texto,
  }) {
    return Row(
      children: [
        Icon(icono, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
            softWrap: true,
          ),
        ),
      ],
    );
  }
}
