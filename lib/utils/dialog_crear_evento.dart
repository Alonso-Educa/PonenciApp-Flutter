import 'package:flutter/material.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/evento.dart';

// ─────────────────────────────────────────────
// DIÁLOGO CREAR / EDITAR EVENTO
// Guarda el evento en Firestore al crear o editar.
// ─────────────────────────────────────────────

class DialogCrearEvento extends StatefulWidget {
  final Evento? eventoEditando;
  final TextEditingController nombreCtrl;
  final TextEditingController fechaCtrl;
  final TextEditingController lugarCtrl;
  final TextEditingController descripcionCtrl;
  final Function(Evento) onGuardar;

  const DialogCrearEvento({
    super.key,
    required this.eventoEditando,
    required this.nombreCtrl,
    required this.fechaCtrl,
    required this.lugarCtrl,
    required this.descripcionCtrl,
    required this.onGuardar,
  });

  @override
  State<DialogCrearEvento> createState() => _DialogCrearEventoState();
}

class _DialogCrearEventoState extends State<DialogCrearEvento> {
  bool _cargando = false;

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
      widget.fechaCtrl.text = '$dd/$mm/${picked.year}';
    }
  }

  void _snack(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _guardar() async {
    if (widget.nombreCtrl.text.trim().isEmpty) {
      _snack('Introduce el nombre del evento');
      return;
    }
    if (widget.fechaCtrl.text.trim().isEmpty) {
      _snack('Introduce la fecha del evento');
      return;
    }
    if (widget.lugarCtrl.text.trim().isEmpty) {
      _snack('Introduce el lugar del evento');
      return;
    }

    setState(() => _cargando = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final firestore = FirebaseFirestore.instance;

      if (widget.eventoEditando == null) {
        // ── Crear nuevo evento ────────────────────────────────
        final codigo = _generarCodigo();
        final ref = firestore.collection('eventos').doc();

        await ref.set({
          'nombre': widget.nombreCtrl.text.trim(),
          'fecha': widget.fechaCtrl.text.trim(),
          'lugar': widget.lugarCtrl.text.trim(),
          'descripcion': widget.descripcionCtrl.text.trim(),
          'codigoEvento': codigo,
          'idOrganizador': uid,
          'contrasena': '',
        });

        widget.onGuardar(
          Evento(
            idEvento: ref.id,
            nombre: widget.nombreCtrl.text.trim(),
            fecha: widget.fechaCtrl.text.trim(),
            lugar: widget.lugarCtrl.text.trim(),
            descripcion: widget.descripcionCtrl.text.trim(),
            codigoEvento: codigo,
          ),
        );
      } else {
        // ── Editar evento existente ───────────────────────────
        await firestore
            .collection('eventos')
            .doc(widget.eventoEditando!.idEvento)
            .update({
              'nombre': widget.nombreCtrl.text.trim(),
              'fecha': widget.fechaCtrl.text.trim(),
              'lugar': widget.lugarCtrl.text.trim(),
              'descripcion': widget.descripcionCtrl.text.trim(),
            });

        widget.onGuardar(
          widget.eventoEditando!.copyWith(
            nombre: widget.nombreCtrl.text.trim(),
            fecha: widget.fechaCtrl.text.trim(),
            lugar: widget.lugarCtrl.text.trim(),
            descripcion: widget.descripcionCtrl.text.trim(),
          ),
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _cargando = false);
      _snack('Error guardando evento: $e');
    }
  }

  String _generarCodigo() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    final code = List.generate(
      4,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
    return 'FORM-$code';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.eventoEditando == null ? 'Crear evento' : 'Editar evento',
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: widget.nombreCtrl,
                enabled: !_cargando,
                decoration: const InputDecoration(
                  labelText: 'Nombre del evento',
                ),
                minLines: 1,
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: widget.fechaCtrl,
                readOnly: true,
                enabled: !_cargando,
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
                enabled: !_cargando,
                decoration: const InputDecoration(labelText: 'Lugar'),
                minLines: 1,
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: widget.descripcionCtrl,
                enabled: !_cargando,
                decoration: const InputDecoration(labelText: 'Descripción'),
                minLines: 2,
                maxLines: 5,
              ),
            ],
          ),
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
              : Text(widget.eventoEditando == null ? 'Crear' : 'Guardar'),
        ),
      ],
    );
  }
}
