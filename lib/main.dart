import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────
// PUNTO DE ENTRADA
// ─────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

// ─────────────────────────────────────────────
// RAÍZ DE LA APLICACIÓN
// Configura el tema, el título y el proveedor de estado global.
// ─────────────────────────────────────────────

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'PonenciApp: Panel de Organizador',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MODELO DE BASE DE DATOS
// Representa a todas las clases de datos registradas en la plataforma.
// ─────────────────────────────────────────────

class Organizador {
  final String idParticipante;
  final String nombre;
  final String apellidos;
  final String emailEduca;
  final String centro;
  final String codigoCentro;
  final String rol;
  final String fechaRegistro;
  final String idEvento;

  Organizador({
    required this.idParticipante,
    required this.nombre,
    required this.apellidos,
    required this.emailEduca,
    required this.centro,
    required this.codigoCentro,
    this.rol = 'organizador',
    this.fechaRegistro = '',
    this.idEvento = '',
  });
}

class Participante {
  final String idParticipante;
  final String nombre;
  final String apellidos;
  final String emailEduca;
  final String centro;
  final String codigoCentro;
  final String rol;
  final String fechaRegistro;
  final String idEvento;

  Participante({
    required this.idParticipante,
    required this.nombre,
    required this.apellidos,
    required this.emailEduca,
    required this.centro,
    required this.codigoCentro,
    this.rol = 'participante',
    this.fechaRegistro = '',
    this.idEvento = '',
  });

  Participante copyWith({
    String? nombre,
    String? apellidos,
    String? emailEduca,
    String? centro,
    String? codigoCentro,
    String? rol,
    String? fechaRegistro,
    String? idEvento,
  }) {
    return Participante(
      idParticipante: idParticipante,
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      emailEduca: emailEduca ?? this.emailEduca,
      centro: centro ?? this.centro,
      codigoCentro: codigoCentro ?? this.codigoCentro,
      rol: rol ?? this.rol,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      idEvento: idEvento ?? this.idEvento,
    );
  }
}

class Evento {
  final String idEvento;
  final String nombre;
  final String fecha;
  final String lugar;
  final String descripcion;
  final String codigoEvento;

  Evento({
    required this.idEvento,
    required this.nombre,
    required this.fecha,
    required this.lugar,
    required this.descripcion,
    required this.codigoEvento,
  });

  Evento copyWith({
    String? nombre,
    String? fecha,
    String? lugar,
    String? descripcion,
    String? codigoEvento,
  }) {
    return Evento(
      idEvento: idEvento,
      nombre: nombre ?? this.nombre,
      fecha: fecha ?? this.fecha,
      lugar: lugar ?? this.lugar,
      descripcion: descripcion ?? this.descripcion,
      codigoEvento: codigoEvento ?? this.codigoEvento,
    );
  }
}

class Ponencia {
  final String idPonencia;
  final String titulo;
  final String ponente;
  final String descripcion;
  final String horaInicio;
  final String horaFin;
  final String qrCode;
  final String idEvento;
  final int orden;

  Ponencia({
    required this.idPonencia,
    required this.titulo,
    required this.ponente,
    required this.descripcion,
    required this.horaInicio,
    required this.horaFin,
    this.qrCode = '',
    required this.idEvento,
    this.orden = 0,
  });

  Ponencia copyWith({
    String? titulo,
    String? ponente,
    String? descripcion,
    String? horaInicio,
    String? horaFin,
    String? qrCode,
    String? idEvento,
    int? orden,
  }) {
    return Ponencia(
      idPonencia: idPonencia,
      titulo: titulo ?? this.titulo,
      ponente: ponente ?? this.ponente,
      descripcion: descripcion ?? this.descripcion,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      qrCode: qrCode ?? this.qrCode,
      idEvento: idEvento ?? this.idEvento,
      orden: orden ?? this.orden,
    );
  }
}

// ─────────────────────────────────────────────
// SCAFFOLD GLOBAL DE LA APLICACIÓN
// Gestiona el scaffold que se ve en todas las
// ventanas
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
      appBar: AppBar(title: Text(title)),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: body,
      floatingActionButton: fab,
    );
  }
}

// ─────────────────────────────────────────────
// ESTADO GLOBAL DE LA APLICACIÓN
// Gestiona la lista de participantes y notifica
// a los widgets cuando hay cambios.
// ─────────────────────────────────────────────

class MyAppState extends ChangeNotifier {
  List<Participante> participantes = [];
  List<Evento> eventos = [];

  void addParticipante(Participante p) {
    participantes.add(p);
    notifyListeners();
  }

  void addEvento(Evento e) {
    eventos.add(e);
    notifyListeners();
  }

  void updateEvento(Evento actualizado) {
    final index = eventos.indexWhere((e) => e.idEvento == actualizado.idEvento);
    if (index != -1) {
      eventos[index] = actualizado;
      notifyListeners();
    }
  }

  void deleteEvento(String idEvento) {
    eventos.removeWhere((e) => e.idEvento == idEvento);
    notifyListeners();
  }
}

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
  // Índice de la sección actualmente seleccionada
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Selecciona la página a mostrar según el índice activo
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = MenuPrincipal();
        break;
      case 1:
        page = CrearParticipante();
        break;
      case 2:
        page = ParticipantesPage();
        break;
      case 3:
        page = EventosPage();
        break;
      // Próximamente login y registro de organizador
      default:
        throw UnimplementedError('No hay widget para el índice $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          // Sin esto el Scaffold muestra su fondo blanco por defecto
          // en los huecos superiores e inferiores del contenido
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  // El rail muestra etiquetas si hay suficiente ancho
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
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              // Área de contenido principal
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// SECCIÓN 0: MENÚ PRINCIPAL
// Pantalla de bienvenida. El contenido funcional
// se añadirá en iteraciones futuras.
// ─────────────────────────────────────────────

class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            '¡Bienvenido a PonenciApp!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Panel de gestión para organizadores de eventos y ponencias.',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          // TODO: Añadir widgets de resumen (próximos eventos, estadísticas, etc.)
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECCIÓN 1: CREAR PARTICIPANTE
// Formulario para registrar un nuevo participante.
// Al pulsar "Aceptar", se validan los campos y se
// añade el participante al estado global.
// ─────────────────────────────────────────────

class CrearParticipante extends StatefulWidget {
  const CrearParticipante({super.key});

  @override
  State<CrearParticipante> createState() => _CrearParticipanteState();
}

class _CrearParticipanteState extends State<CrearParticipante> {
  // Clave para validar el formulario
  final _formKey = GlobalKey<FormState>();

  // Controladores para cada campo del formulario
  final _nombreCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _centroCtrl = TextEditingController();
  final _codigoCentroCtrl = TextEditingController();
  // Formatea DateTime.now() como "dd/MM/yyyy HH:mm:ss",
  // equivalente a SimpleDateFormat("dd/MM/yyyy HH:mm:ss") en Android.
  String _formatearFechaHora(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final ss = dt.second.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy $hh:$min:$ss';
  }

  // Libera los controladores cuando el widget se destruye
  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidosCtrl.dispose();
    _emailCtrl.dispose();
    _centroCtrl.dispose();
    _codigoCentroCtrl.dispose();
    super.dispose();
  }

  // Limpia todos los campos del formulario
  void _limpiarFormulario() {
    _formKey.currentState?.reset();
    _nombreCtrl.clear();
    _apellidosCtrl.clear();
    _emailCtrl.clear();
    _centroCtrl.clear();
    _codigoCentroCtrl.clear();
  }

  // Valida el formulario y, si es correcto, crea y registra el participante
  void _guardarParticipante(MyAppState appState) {
    if (_formKey.currentState!.validate()) {
      final nuevo = Participante(
        idParticipante: DateTime.now().millisecondsSinceEpoch
            .toString(), // id de firebase en el futuro
        nombre: _nombreCtrl.text.trim(),
        apellidos: _apellidosCtrl.text.trim(),
        emailEduca: _emailCtrl.text.trim(),
        centro: _centroCtrl.text.trim(),
        codigoCentro: _codigoCentroCtrl.text.trim(),
        rol: 'participante',
        fechaRegistro: _formatearFechaHora(DateTime.now()),
        idEvento: '',
      );

      appState.addParticipante(nuevo);
      _limpiarFormulario();

      // Confirmación visual al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Participante registrado correctamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    return CustomScaffold(
      title: 'Crear Participante',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            // Limita el ancho del formulario en pantallas grandes
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Cabecera ──────────────────────────────────────
                  const Text(
                    'Registrar nuevo participante',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Completa los datos del participante y pulsa Aceptar.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),

                  // ── Campos del formulario ─────────────────────────
                  _campo(
                    controller: _nombreCtrl,
                    label: 'Nombre',
                    hint: 'Ej: Ana',
                    obligatorio: true,
                  ),
                  _campo(
                    controller: _apellidosCtrl,
                    label: 'Apellidos',
                    hint: 'Ej: García López',
                    obligatorio: true,
                  ),
                  _campo(
                    controller: _emailCtrl,
                    label: 'Email educativo',
                    hint: 'usuario@educa.ejemplo.es',
                    obligatorio: true,
                    teclado: TextInputType.emailAddress,
                    esEmail: true,
                  ),
                  _campo(
                    controller: _centroCtrl,
                    label: 'Centro',
                    hint: 'Nombre del centro educativo',
                    obligatorio: true,
                  ),
                  _campo(
                    controller: _codigoCentroCtrl,
                    label: 'Código de centro',
                    hint: 'Ej: 28001234',
                    obligatorio: true,
                  ),

                  const SizedBox(height: 16),

                  // ── Botones de acción ─────────────────────────────
                  Row(
                    children: [
                      // Botón principal: guarda el participante
                      ElevatedButton.icon(
                        onPressed: () => _guardarParticipante(appState),
                        icon: const Icon(Icons.check),
                        label: const Text('Aceptar'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Botón secundario: limpia el formulario
                      OutlinedButton.icon(
                        onPressed: _limpiarFormulario,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reiniciar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Widget auxiliar: campo de texto con validación opcional ──────────────
  Widget _campo({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obligatorio = false,
    bool esEmail = false,
    TextInputType teclado = TextInputType.text,
  }) {
    final emailPattern = RegExp(
      r'^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: teclado,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
        validator: (value) {
          final texto = value?.trim() ?? '';

          if (obligatorio && texto.isEmpty) {
            return 'Campo obligatorio';
          }

          if (esEmail && texto.isNotEmpty && !emailPattern.hasMatch(texto)) {
            return 'Introduce un correo válido';
          }

          return null;
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECCIÓN 2: LISTA DE PARTICIPANTES
// Muestra en una lista todos los participantes
// registrados hasta el momento.
// ─────────────────────────────────────────────

class ParticipantesPage extends StatelessWidget {
  const ParticipantesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final lista = appState.participantes;

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
                // Contador de participantes
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

                // Una tarjeta por participante con sus datos principales
                for (final p in lista)
                  Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text('${p.nombre} ${p.apellidos}'),
                      subtitle: Text(
                        '${p.emailEduca}\n${p.centro} · ${p.codigoCentro}',
                      ),
                      isThreeLine: true,
                      trailing: Chip(label: Text(p.rol)),
                    ),
                  ),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────
// SECCIÓN 3: EVENTOS Y PONENCIAS
// Aquí se gestionarán los eventos y sus ponencias asociadas.
// ─────────────────────────────────────────────

class EventosPage extends StatelessWidget {
  const EventosPage({super.key});

  void _mostrarDialogoEvento(BuildContext context, Evento? eventoEditando) {
    final appState = context.read<MyAppState>();

    final nombreCtrl = TextEditingController(
      text: eventoEditando?.nombre ?? '',
    );
    final fechaCtrl = TextEditingController(text: eventoEditando?.fecha ?? '');
    final lugarCtrl = TextEditingController(text: eventoEditando?.lugar ?? '');
    final descripcionCtrl = TextEditingController(
      text: eventoEditando?.descripcion ?? '',
    );

    showDialog(
      context: context,
      builder: (_) => _DialogCrearEvento(
        eventoEditando: eventoEditando,
        nombreCtrl: nombreCtrl,
        fechaCtrl: fechaCtrl,
        lugarCtrl: lugarCtrl,
        descripcionCtrl: descripcionCtrl,
        onGuardar: (evento) {
          if (eventoEditando == null) {
            appState.addEvento(evento);
          } else {
            appState.updateEvento(evento);
          }
        },
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, Evento evento) {
    final appState = context.read<MyAppState>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Eliminar evento'),
        content: Text(
          '¿Deseas eliminar el evento "${evento.nombre}"? Esta acción no se puede deshacer.',
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
    final appState = context.watch<MyAppState>();
    final eventos = appState.eventos;

    return CustomScaffold(
      title: 'Eventos',
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetalleEventoPage(evento: evento),
                        ),
                      );
                    },
                    title: Text(
                      evento.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${evento.fecha}\n${evento.lugar}\nCódigo: ${evento.codigoEvento}',
                    ),
                    isThreeLine: true,
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              _mostrarDialogoEvento(context, evento),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () => _confirmarEliminar(context, evento),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      fab: FloatingActionButton(
        onPressed: () => _mostrarDialogoEvento(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DIÁLOGO CREAR / EDITAR EVENTO
// Extraído a StatefulWidget para poder manejar
// el estado del DatePicker y las validaciones.
// ─────────────────────────────────────────────

class _DialogCrearEvento extends StatefulWidget {
  final Evento? eventoEditando;
  final TextEditingController nombreCtrl;
  final TextEditingController fechaCtrl;
  final TextEditingController lugarCtrl;
  final TextEditingController descripcionCtrl;
  final Function(Evento) onGuardar;

  const _DialogCrearEvento({
    required this.eventoEditando,
    required this.nombreCtrl,
    required this.fechaCtrl,
    required this.lugarCtrl,
    required this.descripcionCtrl,
    required this.onGuardar,
  });

  @override
  State<_DialogCrearEvento> createState() => _DialogCrearEventoState();
}

class _DialogCrearEventoState extends State<_DialogCrearEvento> {
  void _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final dd = picked.day.toString().padLeft(2, '0');
      final mm = picked.month.toString().padLeft(2, '0');
      final yyyy = picked.year.toString();
      widget.fechaCtrl.text = '$dd/$mm/$yyyy';
    }
  }

  void _guardar() {
    if (widget.nombreCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce el nombre del evento')),
      );
      return;
    }
    if (widget.fechaCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce la fecha del evento')),
      );
      return;
    }
    if (widget.lugarCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce el lugar del evento')),
      );
      return;
    }

    final evento = Evento(
      idEvento:
          widget.eventoEditando?.idEvento ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: widget.nombreCtrl.text.trim(),
      fecha: widget.fechaCtrl.text.trim(),
      lugar: widget.lugarCtrl.text.trim(),
      descripcion: widget.descripcionCtrl.text.trim(),
      codigoEvento:
          widget.eventoEditando?.codigoEvento ?? _generarCodigoEvento(),
    );

    widget.onGuardar(evento);
    Navigator.pop(context);
  }

  String _generarCodigoEvento() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random(); // Generador aleatorio
    final code = List.generate(
      4,
      (_) => chars[rand.nextInt(chars.length)], // índice aleatorio real
    ).join();
    return 'FORM-$code';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.eventoEditando == null ? 'Crear evento' : 'Editar evento',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: widget.nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre del evento'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: widget.fechaCtrl,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Fecha del evento',
                hintText: 'dd/MM/yyyy',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: _seleccionarFecha,
                ),
              ),
              onTap: _seleccionarFecha,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: widget.lugarCtrl,
              decoration: const InputDecoration(labelText: 'Lugar'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: widget.descripcionCtrl,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _guardar,
          child: Text(widget.eventoEditando == null ? 'Crear' : 'Guardar'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// DETALLE DE EVENTO
// Muestra la información del evento y gestiona
// la lista de ponencias asociadas.
// ─────────────────────────────────────────────

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
      builder: (_) => DialogCrearPonencia(
        onGuardar: (nueva) {
          setState(() {
            ponencias.add(nueva);
            ponencias.sort((a, b) => a.orden.compareTo(b.orden));
          });
        },
        idEvento: widget.evento.idEvento,
        ordenSiguiente: ponencias.length + 1,
      ),
    );
  }

  void _editarPonencia(Ponencia ponencia) {
    showDialog(
      context: context,
      builder: (_) => DialogCrearPonencia(
        ponenciaEditando: ponencia,
        idEvento: widget.evento.idEvento,
        ordenSiguiente: ponencias.length + 1,
        onGuardar: (editada) {
          setState(() {
            ponencias = ponencias.map((p) {
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
              setState(() {
                ponencias.removeWhere(
                  (p) => p.idPonencia == ponencia.idPonencia,
                );
              });
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
      title: widget.evento.nombre,
      fab: FloatingActionButton(
        onPressed: _crearPonencia,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // ── Tarjeta de información del evento ────────────────
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
                  Text('📅 ${evento.fecha}'),
                  Text('📍 ${evento.lugar}'),
                  const SizedBox(height: 8),
                  if (evento.descripcion.isNotEmpty) Text(evento.descripcion),
                  const SizedBox(height: 8),
                  // Código del evento
                  Text(
                    'Código: ${evento.codigoEvento}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Botón QR de check-in
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => _DialogQR(
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

          // ── Cabecera de la lista de ponencias ────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Ponencias (${ponencias.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Lista de ponencias ────────────────────────────────
          Expanded(
            child: ponencias.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.event_note,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'No hay ponencias todavía',
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Pulsa el botón + para añadir una',
                          style: TextStyle(fontSize: 12, color: Colors.black38),
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
                          leading: CircleAvatar(child: Text('${p.orden}')),
                          title: Text(p.titulo),
                          subtitle: Text(
                            '${p.ponente}\n${p.horaInicio} - ${p.horaFin}',
                          ),
                          isThreeLine: true,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetallePonenciaPage(ponencia: p),
                            ),
                          ),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editarPonencia(p),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                onPressed: () => _eliminarPonencia(p),
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
    );
  }
}

class _DialogQR extends StatelessWidget {
  final String titulo;
  final String contenido;

  const _DialogQR({required this.titulo, required this.contenido});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(titulo, textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Placeholder visual hasta integrar qr_flutter
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code, size: 80, color: Colors.black54),
                SizedBox(height: 8),
                Text(
                  'QR pendiente de integrar',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            contenido,
            style: const TextStyle(fontSize: 12, color: Colors.black45),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

class DialogCrearPonencia extends StatefulWidget {
  final Ponencia? ponenciaEditando;
  final String idEvento;
  final int ordenSiguiente;
  final Function(Ponencia) onGuardar;

  const DialogCrearPonencia({
    super.key,
    this.ponenciaEditando,
    required this.idEvento,
    required this.ordenSiguiente,
    required this.onGuardar,
  });

  @override
  State<DialogCrearPonencia> createState() => _DialogCrearPonenciaState();
}

class _DialogCrearPonenciaState extends State<DialogCrearPonencia> {
  late TextEditingController tituloCtrl;
  late TextEditingController ponenteCtrl;
  late TextEditingController descripcionCtrl;
  late TextEditingController inicioCtrl;
  late TextEditingController finCtrl;

  @override
  void initState() {
    super.initState();

    final p = widget.ponenciaEditando;

    tituloCtrl = TextEditingController(text: p?.titulo ?? '');
    ponenteCtrl = TextEditingController(text: p?.ponente ?? '');
    descripcionCtrl = TextEditingController(text: p?.descripcion ?? '');
    inicioCtrl = TextEditingController(text: p?.horaInicio ?? '');
    finCtrl = TextEditingController(text: p?.horaFin ?? '');
  }

  void _guardar() {
    if (tituloCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Introduce el título')));
      return;
    }
    if (ponenteCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Introduce el ponente')));
      return;
    }
    if (inicioCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce la hora de inicio')),
      );
      return;
    }
    if (finCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Introduce la hora de fin')));
      return;
    }
    if (finCtrl.text.trim().compareTo(inicioCtrl.text.trim()) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La hora de fin debe ser posterior a la de inicio'),
        ),
      );
      return;
    }

    final nueva = Ponencia(
      idPonencia:
          widget.ponenciaEditando?.idPonencia ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: tituloCtrl.text.trim(),
      ponente: ponenteCtrl.text.trim(),
      descripcion: descripcionCtrl.text.trim(),
      horaInicio: inicioCtrl.text.trim(),
      horaFin: finCtrl.text.trim(),
      idEvento: widget.idEvento,
      orden: widget.ponenciaEditando?.orden ?? widget.ordenSiguiente,
    );

    widget.onGuardar(nueva);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.ponenciaEditando == null ? 'Nueva ponencia' : 'Editar ponencia',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tituloCtrl,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: ponenteCtrl,
              decoration: const InputDecoration(labelText: 'Ponente'),
            ),
            TextField(
              controller: descripcionCtrl,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            TextField(
              controller: inicioCtrl,
              readOnly: true, // evita que escriban manualmente
              decoration: const InputDecoration(
                labelText: 'Hora de inicio',
                suffixIcon: Icon(Icons.access_time),
              ),
              onTap: () async {
                final hora = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (hora != null) {
                  inicioCtrl.text = hora.format(context);
                }
              },
            ),
            TextField(
              controller: finCtrl,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Hora de fin',
                suffixIcon: Icon(Icons.access_time),
              ),
              onTap: () async {
                final hora = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (hora != null) {
                  finCtrl.text = hora.format(context);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// DETALLE DE PONENCIA
// Muestra la información completa de una ponencia.
// Se accede desde DetalleEventoPage al pulsar una tarjeta.
// ─────────────────────────────────────────────

class DetallePonenciaPage extends StatelessWidget {
  final Ponencia ponencia;

  const DetallePonenciaPage({super.key, required this.ponencia});

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
                // ── Cabecera: título y orden ───────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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

                // ── Tarjeta de datos principales ──────────────────
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

                // ── Sección QR ────────────────────────────────────
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
                    child: ponencia.qrCode.isEmpty
                        ? Row(
                            children: const [
                              Icon(
                                Icons.qr_code,
                                size: 40,
                                color: Colors.black38,
                              ),
                              SizedBox(width: 16),
                              Text(
                                'QR no generado todavía',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          )
                        : Text(ponencia.qrCode),
                    // TODO: Cuando qrCode tenga valor, renderizar el QR aquí
                    // con el paquete qr_flutter: QrImageView(data: ponencia.qrCode)
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Widget auxiliar: fila icono + etiqueta + valor ───────────────────────
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
