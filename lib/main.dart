import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────
// PUNTO DE ENTRADA
// ─────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
// MODELO DE DATOS: PARTICIPANTE
// Representa a un participante registrado en la plataforma.
// ─────────────────────────────────────────────

class Participante {
  String nombre;
  String apellidos;
  String emailEduca;
  String centro;
  String codigoCentro;
  String rol;
  String fechaRegistro;
  String idEvento;

  Participante({
    required this.nombre,
    required this.apellidos,
    required this.emailEduca,
    required this.centro,
    required this.codigoCentro,
    this.rol = 'participante', // Valor por defecto
    required this.fechaRegistro,
    this.idEvento = '',        // Vacío hasta que se asigne a un evento
  });
}

// ─────────────────────────────────────────────
// ESTADO GLOBAL DE LA APLICACIÓN
// Gestiona la lista de participantes y notifica
// a los widgets cuando hay cambios.
// ─────────────────────────────────────────────

class MyAppState extends ChangeNotifier {
  // Lista de participantes registrados
  List<Participante> participantes = [];

  // Añade un participante a la lista y notifica a los oyentes
  void addParticipante(Participante p) {
    participantes.add(p);
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
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.black54,
            ),
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
  final _nombreCtrl        = TextEditingController();
  final _apellidosCtrl     = TextEditingController();
  final _emailCtrl         = TextEditingController();
  final _centroCtrl        = TextEditingController();
  final _codigoCentroCtrl  = TextEditingController();
  // Formatea DateTime.now() como "dd/MM/yyyy HH:mm:ss",
  // equivalente a SimpleDateFormat("dd/MM/yyyy HH:mm:ss") en Android.
  String _formatearFechaHora(DateTime dt) {
    final dd  = dt.day.toString().padLeft(2, '0');
    final mm  = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();
    final hh  = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final ss  = dt.second.toString().padLeft(2, '0');
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
        nombre:        _nombreCtrl.text.trim(),
        apellidos:     _apellidosCtrl.text.trim(),
        emailEduca:    _emailCtrl.text.trim(),
        centro:        _centroCtrl.text.trim(),
        codigoCentro:  _codigoCentroCtrl.text.trim(),
        rol:           'participante', // Valor por defecto; se ampliará al implementar roles
        // La fecha se captura en el momento exacto de guardar, sin exponerla al usuario
        fechaRegistro: _formatearFechaHora(DateTime.now()),
        idEvento:      '', // Se asignará al asociarlo a un evento
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

    return SingleChildScrollView(
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
                            horizontal: 24, vertical: 14),
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
    );
  }

  // ── Widget auxiliar: campo de texto con validación opcional ──────────────
  Widget _campo({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obligatorio = false,
    TextInputType teclado = TextInputType.text,
  }) {
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
        // Si el campo es obligatorio, valida que no esté vacío
        validator: obligatorio
            ? (value) =>
                (value == null || value.trim().isEmpty) ? 'Campo obligatorio' : null
            : null,
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
    final lista    = appState.participantes;

    // Estado vacío
    if (lista.isEmpty) {
      return const Center(
        child: Text(
          'No hay participantes registrados aún.',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [

        // Contador de participantes
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            '${lista.length} participante(s) registrado(s)',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    );
  }
}

// ─────────────────────────────────────────────
// SECCIÓN 3: EVENTOS Y PONENCIAS
// Pendiente de implementación futura.
// Aquí se gestionarán los eventos y sus ponencias asociadas.
// ─────────────────────────────────────────────

class EventosPage extends StatelessWidget {
  const EventosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event, size: 80, color: theme.colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'Eventos y Ponencias',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Esta sección está pendiente de implementación.',
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
          // TODO: Implementar creación y listado de eventos y ponencias
        ],
      ),
    );
  }
}