import 'package:flutter/material.dart';
import 'package:ponenciapp/models/organizador.dart';
import '../models/participante.dart';
import '../models/evento.dart';

// ─────────────────────────────────────────────
// ESTADO GLOBAL DE LA APLICACIÓN
// Gestiona la lista de participantes y notifica a los widgets cuando hay cambios.
// ─────────────────────────────────────────────
class MyAppState extends ChangeNotifier {
  List<Participante> participantes = [];
  List<Evento> eventos = [];
  List<Organizador> organizadores = [];

  // Organizador que ha iniciado sesión actualmente
  Organizador? organizadorActual;

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

  void addOrganizador(Organizador o) {
    organizadores.add(o);
    notifyListeners();
  }

  // Devuelve el organizador si email y password coinciden, null si no
  Organizador? login(String email, String password) {
    try {
      return organizadores.firstWhere(
        (o) => o.emailEduca == email && o.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  void cerrarSesion() {
    organizadorActual = null;
    notifyListeners();
  }
}