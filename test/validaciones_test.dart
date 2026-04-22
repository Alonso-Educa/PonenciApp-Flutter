// test/unit/validaciones_test.dart
//
// Tests de CAJA BLANCA para PonenciApp.
// Cada test lleva su ID (CBxx) correspondiente a la tabla de casos de prueba.
//
// Ejecutar con:
//   flutter test test/unit/validaciones_test.dart
//
// ┌──────┬──────────────────────────────┬──────────────────────────────────────┬──────────────────────────┬──────────────────────────────────────┬──────────────┐
// │  ID  │ Método                       │ Condición / Camino                   │ Entrada                  │ Resultado esperado                   │ Tipo         │
// ├──────┼──────────────────────────────┼──────────────────────────────────────┼──────────────────────────┼──────────────────────────────────────┼──────────────┤
// │ CB01 │ emailEsValido()              │ email vacío → false                  │ ""                       │ false                                │ Frontera     │
// │ CB02 │ emailEsValido()              │ sin @ → no coincide regex            │ "usuariosinarroba.com"   │ false                                │ Inválido     │
// │ CB03 │ emailEsValido()              │ sin dominio tras @                   │ "usuario@"               │ false                                │ Inválido     │
// │ CB04 │ emailEsValido()              │ formato correcto → true              │ "user@educa.junta.es"    │ true                                 │ Camino feliz │
// ├──────┼──────────────────────────────┼──────────────────────────────────────┼──────────────────────────┼──────────────────────────────────────┼──────────────┤
// │ CB05 │ validarPasswordLogin()       │ vacía → 1ª guard                     │ ""                       │ 'Introduce tu contraseña'            │ Frontera     │
// │ CB06 │ validarPasswordLogin()       │ length=5, frontera inferior          │ "abcde"                  │ 'La contraseña debe tener...'        │ Valor límite │
// │ CB07 │ validarPasswordLogin()       │ length=6, frontera exacta → null     │ "abcdef"                 │ null                                 │ Valor límite │
// │ CB08 │ validarPasswordParticipante()│ vacía → mensaje distinto al login    │ ""                       │ 'Campo obligatorio'                  │ Frontera     │
// ├──────┼──────────────────────────────┼──────────────────────────────────────┼──────────────────────────┼──────────────────────────────────────┼──────────────┤
// │ CB09 │ validarPasswordRegistro()    │ vacía → 1ª guard                     │ ""                       │ 'Campo obligatorio'                  │ Frontera     │
// │ CB10 │ validarPasswordRegistro()    │ length=9, frontera inferior          │ "abcde!@#1"              │ 'Mínimo 10 caracteres'               │ Valor límite │
// │ CB11 │ validarPasswordRegistro()    │ length=10, sin especial → 3ª guard   │ "abcdefghij"             │ 'Debe incluir al menos un carácter…' │ Camino alt.  │
// │ CB12 │ validarPasswordRegistro()    │ length=10, con especial → null       │ "abcde!@#1X"             │ null                                 │ Camino feliz │
// ├──────┼──────────────────────────────┼──────────────────────────────────────┼──────────────────────────┼──────────────────────────────────────┼──────────────┤
// │ CB13 │ validarCampoObligatorio()    │ vacío → error                        │ ""                       │ 'Campo obligatorio'                  │ Frontera     │
// │ CB14 │ validarCampoObligatorio()    │ null → ?? → vacío                    │ null                     │ 'Campo obligatorio'                  │ Frontera     │
// │ CB15 │ validarCampoObligatorio()    │ con texto → null                     │ "Ana García"             │ null                                 │ Camino feliz │
// ├──────┼──────────────────────────────┼──────────────────────────────────────┼──────────────────────────┼──────────────────────────────────────┼──────────────┤
// │ CB16 │ horaFinEsValida()            │ fin == inicio → false                │ "10:00","10:00"          │ false                                │ Frontera     │
// │ CB17 │ horaFinEsValida()            │ fin < inicio → false                 │ "17:00","09:00"          │ false                                │ Inválido     │
// │ CB18 │ horaFinEsValida()            │ fin > inicio → true                  │ "09:00","17:30"          │ true                                 │ Camino feliz │
// ├──────┼──────────────────────────────┼──────────────────────────────────────┼──────────────────────────┼──────────────────────────────────────┼──────────────┤
// │ CB19 │ generarCodigoEvento()        │ formato FORM- + 4 alfanuméricos      │ (generado)               │ pasa codigoEventoEsValido()          │ Camino feliz │
// │ CB20 │ codigoEventoEsValido()       │ formato correcto → true              │ "FORM-Ab1Z"              │ true                                 │ Camino feliz │
// │ CB21 │ codigoEventoEsValido()       │ sin prefijo FORM-                    │ "AB12"                   │ false                                │ Inválido     │
// │ CB22 │ codigoEventoEsValido()       │ contiene carácter especial           │ "FORM-AB1!"              │ false                                │ Inválido     │
// ├──────┼──────────────────────────────┼──────────────────────────────────────┼──────────────────────────┼──────────────────────────────────────┼──────────────┤
// │ CB23 │ formatearFechaHora()         │ fecha con padding de ceros           │ DateTime(2025,1,5,8,3,7) │ '05/01/2025 08:03:07'                │ Camino feliz │
// │ CB24 │ formatearFechaHora()         │ medianoche exacta (frontera)         │ DateTime(2025,1,1,0,0,0) │ '01/01/2025 00:00:00'                │ Frontera     │
// │ CB25 │ parsearFechaEvento()         │ formato correcto dd/MM/yyyy          │ "25/12/2025"             │ DateTime(2025,12,25)                 │ Camino feliz │
// │ CB26 │ parsearFechaEvento()         │ formato incorrecto → null            │ "25-12-2025"             │ null                                 │ Inválido     │
// ├──────┼──────────────────────────────┼──────────────────────────────────────┼──────────────────────────┼──────────────────────────────────────┼──────────────┤
// │ CB27 │ Evento.copyWith()            │ modifica solo nombre                 │ nombre: 'Nuevo'          │ nombre cambia, resto igual           │ Camino feliz │
// │ CB28 │ Participante.copyWith()      │ sin parámetros → copia idéntica      │ (ninguno)                │ todos los campos iguales             │ Frontera     │
// └──────┴──────────────────────────────┴──────────────────────────────────────┴──────────────────────────┴──────────────────────────────────────┴──────────────┘

import 'package:flutter_test/flutter_test.dart';
import 'package:ponenciapp/utils/validaciones.dart';
import 'package:ponenciapp/models/evento.dart';
import 'package:ponenciapp/models/participante.dart';

void main() {
  // ════════════════════════════════════════════════════════════════
  // GRUPO 1 — emailEsValido()
  // Fuente: _emailPattern en LoginPage y _campo(esEmail:true) en RegistroPage
  // ════════════════════════════════════════════════════════════════
  group('CB01-CB04 · emailEsValido()', () {
    test('CB01: email vacío devuelve false', () {
      expect(Validaciones.emailEsValido(''), false);
    });

    test('CB02: email sin @ devuelve false', () {
      expect(Validaciones.emailEsValido('usuariosinarroba.com'), false);
    });

    test('CB03: email sin dominio tras @ devuelve false', () {
      expect(Validaciones.emailEsValido('usuario@'), false);
    });

    test('CB04: email con formato correcto devuelve true', () {
      expect(Validaciones.emailEsValido('user@educa.junta.es'), true);
    });
  });

  // ════════════════════════════════════════════════════════════════
  // GRUPO 2 — Contraseñas con mínimo 6 caracteres (login + participante)
  // Ambas funciones comparten la misma lógica (min 6 chars).
  // Se prueba login a fondo y se verifica que participante devuelve un mensaje distinto para el caso vacío.
  // ════════════════════════════════════════════════════════════════
  group('CB05-CB08 · validarPasswordLogin() + validarPasswordParticipante()', () {
    test('CB05: login vacía devuelve "Introduce tu contraseña"', () {
      expect(Validaciones.validarPasswordLogin(''), 'Introduce tu contraseña');
    });

    test(
      'CB06: login de 5 chars (frontera inferior) devuelve error de longitud',
      () {
        expect(
          Validaciones.validarPasswordLogin('abcde'),
          'La contraseña debe tener al menos 6 caracteres',
        );
      },
    );

    test('CB07: login de exactamente 6 chars devuelve null (válida)', () {
      expect(Validaciones.validarPasswordLogin('abcdef'), null);
    });

    test(
      'CB08: participante vacía devuelve "Campo obligatorio" (mensaje distinto al login)',
      () {
        expect(
          Validaciones.validarPasswordParticipante(''),
          'Campo obligatorio',
        );
      },
    );
  });

  // ════════════════════════════════════════════════════════════════
  // GRUPO 3 — validarPasswordRegistro()
  // Fuente: validator del TextFormField en RegistroOrganizadorPage
  // Caminos:
  //   vacía → 'Campo obligatorio'
  //   length<10 → 'Mínimo 10 caracteres'
  //   sin especial → 'Debe incluir al menos un carácter especial'
  //   ok → null
  // ════════════════════════════════════════════════════════════════
  group('CB09-CB12 · validarPasswordRegistro()', () {
    test('CB09: contraseña vacía devuelve "Campo obligatorio"', () {
      expect(Validaciones.validarPasswordRegistro(''), 'Campo obligatorio');
    });

    test(
      'CB10: contraseña de 9 chars (frontera inferior) devuelve error de longitud',
      () {
        expect(
          Validaciones.validarPasswordRegistro('abcde!@#1'),
          'Mínimo 10 caracteres',
        );
      },
    );

    test(
      'CB11: contraseña de 10 chars sin especial devuelve error de carácter especial',
      () {
        expect(
          Validaciones.validarPasswordRegistro('abcdefghij'),
          'Debe incluir al menos un carácter especial',
        );
      },
    );

    test(
      'CB12: contraseña de 10+ chars con especial devuelve null (válida)',
      () {
        expect(Validaciones.validarPasswordRegistro('abcde!@#1X'), null);
      },
    );
  });

  // ════════════════════════════════════════════════════════════════
  // GRUPO 4 — validarCampoObligatorio()
  // Fuente: helper _campo(obligatorio:true) en RegistroOrganizadorPage
  // Aplica a: nombre, apellidos, centro, codigoCentro
  // ════════════════════════════════════════════════════════════════
  group('CB13-CB15 · validarCampoObligatorio()', () {
    test('CB13: campo vacío devuelve "Campo obligatorio"', () {
      expect(Validaciones.validarCampoObligatorio(''), 'Campo obligatorio');
    });

    test('CB14: null devuelve "Campo obligatorio"', () {
      expect(Validaciones.validarCampoObligatorio(null), 'Campo obligatorio');
    });

    test('CB15: campo con texto devuelve null (válido)', () {
      expect(Validaciones.validarCampoObligatorio('Ana García'), null);
    });
  });

  // ════════════════════════════════════════════════════════════════
  // GRUPO 5 — horaFinEsValida()
  // Fuente: guard en _guardar() de DialogCrearPonencia
  //   if (finCtrl.text.compareTo(inicioCtrl.text) <= 0) → error
  // ════════════════════════════════════════════════════════════════
  group('CB16-CB18 · horaFinEsValida()', () {
    test('CB16: fin igual a inicio devuelve false', () {
      expect(Validaciones.horaFinEsValida('10:00', '10:00'), false);
    });

    test('CB17: fin anterior a inicio devuelve false', () {
      expect(Validaciones.horaFinEsValida('17:00', '09:00'), false);
    });

    test('CB18: fin posterior a inicio devuelve true (camino feliz)', () {
      expect(Validaciones.horaFinEsValida('09:00', '17:30'), true);
    });
  });

  // ════════════════════════════════════════════════════════════════
  // GRUPO 6 — Código de evento (generador + validador)
  // Fuente: _generarCodigo() de DialogCrearEvento
  // Formato: 'FORM-' + 4 chars de [A-Za-z0-9]
  // ════════════════════════════════════════════════════════════════
  group('CB19-CB22 · generarCodigoEvento() + codigoEventoEsValido()', () {
    test('CB19: el código generado siempre pasa la validación', () {
      // Se generan 50 códigos para cubrir aleatoriedad sin ser flaky
      for (int i = 0; i < 50; i++) {
        final codigo = Validaciones.generarCodigoEvento();
        expect(
          Validaciones.codigoEventoEsValido(codigo),
          true,
          reason: 'El código generado "$codigo" debería ser válido',
        );
      }
    });

    test('CB20: código con formato correcto devuelve true', () {
      expect(Validaciones.codigoEventoEsValido('FORM-Ab1Z'), true);
    });

    test('CB21: código sin prefijo FORM- devuelve false', () {
      expect(Validaciones.codigoEventoEsValido('AB12'), false);
    });

    test('CB22: código con carácter especial devuelve false', () {
      expect(Validaciones.codigoEventoEsValido('FORM-AB1!'), false);
    });
  });

  // ════════════════════════════════════════════════════════════════
  // GRUPO 7 — Fechas (formatear + parsear)
  // Fuentes:
  //   · _formatearFechaHora() en crear_participante.dart (líneas 48-55)
  //   · parseo de fecha en estadisticas_page.dart (líneas 84-90)
  // ════════════════════════════════════════════════════════════════
  group('CB23-CB26 · formatearFechaHora() + parsearFechaEvento()', () {
    test('CB23: formatear fecha con padding de ceros', () {
      expect(
        Validaciones.formatearFechaHora(DateTime(2025, 1, 5, 8, 3, 7)),
        '05/01/2025 08:03:07',
      );
    });

    test('CB24: formatear medianoche exacta (frontera)', () {
      expect(
        Validaciones.formatearFechaHora(DateTime(2025, 1, 1, 0, 0, 0)),
        '01/01/2025 00:00:00',
      );
    });

    test('CB25: parsear fecha con formato correcto dd/MM/yyyy', () {
      final resultado = Validaciones.parsearFechaEvento('25/12/2025');
      expect(resultado, DateTime(2025, 12, 25));
    });

    test('CB26: parsear fecha con formato incorrecto devuelve null', () {
      expect(Validaciones.parsearFechaEvento('25-12-2025'), null);
    });
  });

  // ════════════════════════════════════════════════════════════════
  // GRUPO 8 — Modelos copyWith()
  // Todos los modelos usan el mismo patrón (campo ?? this.campo).
  // Se prueba Evento (modelo simple) y Participante (modelo complejo)
  // como representantes del patrón.
  // ════════════════════════════════════════════════════════════════
  group('CB27-CB28 · Modelos copyWith()', () {
    test('CB27: Evento.copyWith() modifica solo nombre, resto se mantiene', () {
      final evento = Evento(
        idEvento: 'e1',
        nombre: 'Evento Original',
        fecha: '01/01/2025',
        lugar: 'Sala A',
        descripcion: 'Descripción del evento',
        codigoEvento: 'FORM-Ab1Z',
      );

      final copia = evento.copyWith(nombre: 'Evento Nuevo');

      expect(copia.nombre, 'Evento Nuevo');
      expect(copia.idEvento, 'e1');
      expect(copia.fecha, '01/01/2025');
      expect(copia.lugar, 'Sala A');
      expect(copia.descripcion, 'Descripción del evento');
      expect(copia.codigoEvento, 'FORM-Ab1Z');
    });

    test(
      'CB28: Participante.copyWith() sin parámetros devuelve copia idéntica',
      () {
        final participante = Participante(
          idParticipante: 'p1',
          nombre: 'Ana',
          apellidos: 'García López',
          emailEduca: 'ana@educa.es',
          centro: 'IES Ejemplo',
          codigoCentro: '28001',
          rol: 'participante',
          fechaRegistro: '01/01/2025 10:00:00',
          idEvento: 'e1',
          password: 'miPassword1!',
          fotoPerfilUrl: '',
        );

        final copia = participante.copyWith();

        expect(copia.idParticipante, participante.idParticipante);
        expect(copia.nombre, participante.nombre);
        expect(copia.apellidos, participante.apellidos);
        expect(copia.emailEduca, participante.emailEduca);
        expect(copia.centro, participante.centro);
        expect(copia.codigoCentro, participante.codigoCentro);
        expect(copia.rol, participante.rol);
        expect(copia.fechaRegistro, participante.fechaRegistro);
        expect(copia.idEvento, participante.idEvento);
        expect(copia.password, participante.password);
        expect(copia.fotoPerfilUrl, participante.fotoPerfilUrl);
      },
    );
  });
}
