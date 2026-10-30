class Participante {
  final String id;
  final String nombre;
  bool yaRecibioTurno;

  Participante({
    required this.id,
    required this.nombre,
    this.yaRecibioTurno = false,
  });
}
