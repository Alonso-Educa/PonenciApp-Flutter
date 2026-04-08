import 'package:flutter/material.dart';
import '../models/ponencia.dart';

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

  @override
  void dispose() {
    tituloCtrl.dispose();
    ponenteCtrl.dispose();
    descripcionCtrl.dispose();
    inicioCtrl.dispose();
    finCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarHora(TextEditingController ctrl) async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (hora != null) {
      final h = hora.hour.toString().padLeft(2, '0');
      final m = hora.minute.toString().padLeft(2, '0');
      ctrl.text = '$h:$m';
    }
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
      title: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
        child: Text(
          widget.ponenciaEditando == null
              ? 'Nueva ponencia'
              : 'Editar ponencia',
          softWrap: true, // asegura que haga wrap
        ),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 300,
          maxWidth: 400,
        ), // ancho máximo
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tituloCtrl,
                decoration: const InputDecoration(labelText: 'Título'),
                minLines: 1,
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ponenteCtrl,
                decoration: const InputDecoration(labelText: 'Ponente'),
                minLines: 1,
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descripcionCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
                minLines: 2,
                maxLines: 5,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: inicioCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Hora de inicio',
                  suffixIcon: Icon(Icons.access_time),
                ),
                onTap: () => _seleccionarHora(inicioCtrl),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: finCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Hora de fin',
                  suffixIcon: Icon(Icons.access_time),
                ),
                onTap: () => _seleccionarHora(finCtrl),
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
        ElevatedButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }
}
