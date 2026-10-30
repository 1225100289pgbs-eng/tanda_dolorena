import '../modelos/cierre_ronda.dart';
import '../modelos/tanda.dart';
import 'resultado_aportacion.dart';
import 'resultado_cierre.dart';

class ServicioTanda {
  final Tanda tanda;

  ServicioTanda(this.tanda);

  bool haTerminado() => tanda.turnoActual >= tanda.ordenTurnos.length;

  ResultadoAportacion registrarAportacion(String idParticipante) {
    if (haTerminado()) return ResultadoAportacion.tandaTerminada;

    final esParticipante =
        tanda.participantes.any((participante) => participante.id == idParticipante);
    if (!esParticipante) return ResultadoAportacion.participanteInvalido;

    final yaAporto = tanda.aportacionesRondaActual.contains(idParticipante);
    if (yaAporto) return ResultadoAportacion.yaAporto;

    tanda.aportacionesRondaActual.add(idParticipante);
    return ResultadoAportacion.registrada;
  }

  bool puedeCerrarRonda() {
    if (haTerminado() || tanda.participantes.isEmpty) return false;
    return tanda.participantes.every(
      (participante) =>
          tanda.aportacionesRondaActual.contains(participante.id),
    );
  }

  CierreRonda cerrarRondaYAvanzar() {
    if (haTerminado()) {
      return CierreRonda(ResultadoCierre.tandaYaTermino, null);
    }

    if (!puedeCerrarRonda()) {
      return CierreRonda(ResultadoCierre.faltanAportaciones, null);
    }

    final idBeneficiario = tanda.ordenTurnos[tanda.turnoActual];
    final beneficiario = tanda.participantes.firstWhere(
      (participante) => participante.id == idBeneficiario,
    );

    beneficiario.yaRecibioTurno = true;
    tanda.aportacionesRondaActual.clear();
    tanda.turnoActual++;

    return CierreRonda(ResultadoCierre.rondaCerrada, beneficiario);
  }
}
