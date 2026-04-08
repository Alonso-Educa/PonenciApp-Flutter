import 'package:flutter/material.dart';
import '../models/participante.dart';
import '../models/evento.dart';

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