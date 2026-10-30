import 'participante.dart';

class Tanda {
  final List<Participante> participantes;
  final List<String> ordenTurnos;
  final double montoAportacion;
  int turnoActual;
  final Set<String> aportacionesRondaActual;

  Tanda({
    required this.participantes,
    required this.ordenTurnos,
    required this.montoAportacion,
    this.turnoActual = 0,
    Set<String>? aportacionesRondaActual,
  }) : aportacionesRondaActual = aportacionesRondaActual ?? <String>{};
}
