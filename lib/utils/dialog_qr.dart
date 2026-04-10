import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class DialogQR extends StatelessWidget {
  final String titulo;
  final String contenido;

  const DialogQR({super.key, required this.titulo, required this.contenido});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(titulo, textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: PrettyQrView.data(data: contenido),
          ),
          const SizedBox(height: 12),
          Text(
            contenido,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black45),
          ),
        ],
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ),
      ],
    );
  }
}
