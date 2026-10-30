import 'package:flutter_test/flutter_test.dart';
import 'package:tanda_dolorena/logica/resultado_aportacion.dart';
import 'package:tanda_dolorena/logica/resultado_cierre.dart';
import 'package:tanda_dolorena/logica/servicio_tanda.dart';
import 'package:tanda_dolorena/modelos/participante.dart';
import 'package:tanda_dolorena/modelos/tanda.dart';

Tanda _crearTandaDePrueba() {
  return Tanda(
    participantes: [
      Participante(id: 'p1', nombre: 'Ana'),
      Participante(id: 'p2', nombre: 'Beto'),
      Participante(id: 'p3', nombre: 'Carla'),
    ],
    ordenTurnos: ['p1', 'p2', 'p3'],
    montoAportacion: 200,
  );
}

void _completarRonda(ServicioTanda servicio) {
  for (final id in ['p1', 'p2', 'p3']) {
    servicio.registrarAportacion(id);
  }
}

void main() {
  test('registra una aportación válida en la ronda actual', () {
    final tanda = _crearTandaDePrueba();
    final servicio = ServicioTanda(tanda);

    final resultado = servicio.registrarAportacion('p1');

    expect(resultado, ResultadoAportacion.registrada);
    expect(tanda.aportacionesRondaActual.contains('p1'), isTrue);
  });

  test('un participante no puede aportar dos veces en la misma ronda', () {
    final servicio = ServicioTanda(_crearTandaDePrueba());
    servicio.registrarAportacion('p1');

    final resultado = servicio.registrarAportacion('p1');

    expect(resultado, ResultadoAportacion.yaAporto);
  });

  test('rechaza aportaciones de alguien que no pertenece a la tanda', () {
    final servicio = ServicioTanda(_crearTandaDePrueba());

    final resultado = servicio.registrarAportacion('desconocido');

    expect(resultado, ResultadoAportacion.participanteInvalido);
  });

  test('puedeCerrarRonda es falso si falta alguien por aportar', () {
    final servicio = ServicioTanda(_crearTandaDePrueba());
    servicio.registrarAportacion('p1');
    servicio.registrarAportacion('p2');

    expect(servicio.puedeCerrarRonda(), isFalse);
  });

  test('puedeCerrarRonda es verdadero cuando todos aportaron', () {
    final servicio = ServicioTanda(_crearTandaDePrueba());
    _completarRonda(servicio);

    expect(servicio.puedeCerrarRonda(), isTrue);
  });

  test('cerrar ronda entrega el turno al beneficiario y avanza', () {
    final tanda = _crearTandaDePrueba();
    final servicio = ServicioTanda(tanda);
    _completarRonda(servicio);

    final cierre = servicio.cerrarRondaYAvanzar();

    expect(cierre.resultado, ResultadoCierre.rondaCerrada);
    expect(cierre.beneficiario!.id, 'p1');
    expect(tanda.participantes.firstWhere((p) => p.id == 'p1').yaRecibioTurno, isTrue);
    expect(tanda.turnoActual, 1);
    expect(tanda.aportacionesRondaActual, isEmpty);
  });

  test('no cierra la ronda si falta una aportación y no avanza', () {
    final tanda = _crearTandaDePrueba();
    final servicio = ServicioTanda(tanda);
    servicio.registrarAportacion('p1');
    servicio.registrarAportacion('p2');

    final cierre = servicio.cerrarRondaYAvanzar();

    expect(cierre.resultado, ResultadoCierre.faltanAportaciones);
    expect(cierre.beneficiario, isNull);
    expect(tanda.turnoActual, 0);
  });

  test('haTerminado es falso mientras queden turnos pendientes', () {
    final servicio = ServicioTanda(_crearTandaDePrueba());

    expect(servicio.haTerminado(), isFalse);
  });

  test('haTerminado es verdadero cuando todos recibieron su turno', () {
    final servicio = ServicioTanda(_crearTandaDePrueba());

    for (var i = 0; i < 3; i++) {
      _completarRonda(servicio);
      servicio.cerrarRondaYAvanzar();
    }

    expect(servicio.haTerminado(), isTrue);
  });

  test('no permite aportar después de que la tanda terminó', () {
    final servicio = ServicioTanda(_crearTandaDePrueba());

    for (var i = 0; i < 3; i++) {
      _completarRonda(servicio);
      servicio.cerrarRondaYAvanzar();
    }

    expect(
      servicio.registrarAportacion('p1'),
      ResultadoAportacion.tandaTerminada,
    );
  });

  test('simulación completa respeta el orden de beneficiarios', () {
    final tanda = _crearTandaDePrueba();
    final servicio = ServicioTanda(tanda);
    final beneficiarios = <String>[];

    while (!servicio.haTerminado()) {
      _completarRonda(servicio);
      final cierre = servicio.cerrarRondaYAvanzar();
      expect(cierre.resultado, ResultadoCierre.rondaCerrada);
      beneficiarios.add(cierre.beneficiario!.id);
    }

    expect(beneficiarios, ['p1', 'p2', 'p3']);
    expect(tanda.participantes.every((p) => p.yaRecibioTurno), isTrue);
    expect(
      servicio.registrarAportacion('p1'),
      ResultadoAportacion.tandaTerminada,
    );
  });
}
