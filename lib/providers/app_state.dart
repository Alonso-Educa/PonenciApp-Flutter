import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  Organizador? organizadorActual;

  // Tema
  ThemeMode themeMode = ThemeMode.light;
  bool get isDarkTheme => themeMode == ThemeMode.dark;

  void toggleTheme() {
    themeMode = isDarkTheme ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  // Participantes
  void addParticipante(Participante p) {
    participantes.add(p);
    notifyListeners();
  }

  // Eventos
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

  // Organizadores
  void actualizarOrganizadorActual(Organizador actualizado) {
    organizadorActual = actualizado;
    notifyListeners();
  }

  // Gestión de cuenta
  Future<void> cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    organizadorActual = null;
    eventos.clear();
    participantes.clear();
    notifyListeners();
  }

  Future<void> eliminarCuenta() async {
    // Auth y Firestore ya se gestionan en el diálogo antes de llamar aquí
    // Solo limpiamos el estado local
    organizadorActual = null;
    eventos.clear();
    participantes.clear();
    notifyListeners();
  }
}
