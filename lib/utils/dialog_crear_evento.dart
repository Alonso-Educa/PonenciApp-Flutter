import 'package:flutter/material.dart';
import 'dart:math';
import '../models/evento.dart';

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
      codigoEvento: widget.eventoEditando?.codigoEvento ?? _generarCodigo(),
    );

    widget.onGuardar(evento);
    Navigator.pop(context);
  }

  String _generarCodigo() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
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
        constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: widget.nombreCtrl,
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
                minLines: 1,
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: widget.descripcionCtrl,
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
