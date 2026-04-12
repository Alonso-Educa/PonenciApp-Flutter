import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ponencia.dart';

// ─────────────────────────────────────────────
// DIÁLOGO CREAR / EDITAR PONENCIA
// Guarda la ponencia en Firestore al crear o editar.
// ─────────────────────────────────────────────

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
  bool _cargando = false;

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

  @override
  void dispose() {
    tituloCtrl.dispose();
    ponenteCtrl.dispose();
    descripcionCtrl.dispose();
    inicioCtrl.dispose();
    finCtrl.dispose();
    super.dispose();
  }

  void _snack(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _seleccionarHora(TextEditingController ctrl) async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (hora != null) {
      final h = hora.hour.toString().padLeft(2, '0');
      final m = hora.minute.toString().padLeft(2, '0');
      ctrl.text = '$h:$m';
    }
  }

  Future<void> _guardar() async {
    if (tituloCtrl.text.trim().isEmpty) {
      _snack('Introduce el título');
      return;
    }
    if (ponenteCtrl.text.trim().isEmpty) {
      _snack('Introduce el ponente');
      return;
    }
    if (inicioCtrl.text.trim().isEmpty) {
      _snack('Introduce la hora de inicio');
      return;
    }
    if (finCtrl.text.trim().isEmpty) {
      _snack('Introduce la hora de fin');
      return;
    }
    if (finCtrl.text.trim().compareTo(inicioCtrl.text.trim()) <= 0) {
      _snack('La hora de fin debe ser posterior a la de inicio');
      return;
    }

    setState(() => _cargando = true);

    try {
      final firestore = FirebaseFirestore.instance;
      final orden = widget.ponenciaEditando?.orden ?? widget.ordenSiguiente;

      final data = {
        'titulo': tituloCtrl.text.trim(),
        'ponente': ponenteCtrl.text.trim(),
        'descripcion': descripcionCtrl.text.trim(),
        'horaInicio': inicioCtrl.text.trim(),
        'horaFin': finCtrl.text.trim(),
        'idEvento': widget.idEvento,
        'orden': orden,
        'qrCode': widget.ponenciaEditando?.qrCode ?? '',
      };

      if (widget.ponenciaEditando == null) {
        // ── Crear nueva ponencia ────────────────────────────
        final ref = firestore.collection('ponencias').doc();
        await ref.set(data);

        widget.onGuardar(Ponencia(
          idPonencia: ref.id,
          titulo: tituloCtrl.text.trim(),
          ponente: ponenteCtrl.text.trim(),
          descripcion: descripcionCtrl.text.trim(),
          horaInicio: inicioCtrl.text.trim(),
          horaFin: finCtrl.text.trim(),
          idEvento: widget.idEvento,
          orden: orden,
        ));
      } else {
        // ── Editar ponencia existente ────────────────────────
        await firestore
            .collection('ponencias')
            .doc(widget.ponenciaEditando!.idPonencia)
            .update(data);

        widget.onGuardar(widget.ponenciaEditando!.copyWith(
          titulo: tituloCtrl.text.trim(),
          ponente: ponenteCtrl.text.trim(),
          descripcion: descripcionCtrl.text.trim(),
          horaInicio: inicioCtrl.text.trim(),
          horaFin: finCtrl.text.trim(),
        ));
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _cargando = false);
      _snack('Error guardando ponencia: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.ponenciaEditando == null
            ? 'Nueva ponencia'
            : 'Editar ponencia',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tituloCtrl,
              enabled: !_cargando,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: ponenteCtrl,
              enabled: !_cargando,
              decoration: const InputDecoration(labelText: 'Ponente'),
            ),
            TextField(
              controller: descripcionCtrl,
              enabled: !_cargando,
              decoration:
                  const InputDecoration(labelText: 'Descripción'),
            ),
            TextField(
              controller: inicioCtrl,
              readOnly: true,
              enabled: !_cargando,
              decoration: const InputDecoration(
                labelText: 'Hora de inicio',
                suffixIcon: Icon(Icons.access_time),
              ),
              onTap: () => _seleccionarHora(inicioCtrl),
            ),
            TextField(
              controller: finCtrl,
              readOnly: true,
              enabled: !_cargando,
              decoration: const InputDecoration(
                labelText: 'Hora de fin',
                suffixIcon: Icon(Icons.access_time),
              ),
              onTap: () => _seleccionarHora(finCtrl),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cargando ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _cargando ? null : _guardar,
          child: _cargando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}