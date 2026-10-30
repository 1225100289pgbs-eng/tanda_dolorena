import 'package:flutter/material.dart';

import '../logica/resultado_aportacion.dart';
import '../logica/resultado_cierre.dart';
import '../logica/servicio_tanda.dart';
import '../modelos/participante.dart';
import '../modelos/tanda.dart';

class TandaScreen extends StatefulWidget {
  const TandaScreen({super.key});

  @override
  State<TandaScreen> createState() => _TandaScreenState();
}

class _TandaScreenState extends State<TandaScreen> {
  late final Tanda _tanda;
  late final ServicioTanda _servicio;

  @override
  void initState() {
    super.initState();
    _tanda = Tanda(
      participantes: [
        Participante(id: 'p1', nombre: 'Ana'),
        Participante(id: 'p2', nombre: 'Beto'),
        Participante(id: 'p3', nombre: 'Carla'),
        Participante(id: 'p4', nombre: 'Diego'),
      ],
      ordenTurnos: ['p1', 'p2', 'p3', 'p4'],
      montoAportacion: 200,
    );
    _servicio = ServicioTanda(_tanda);
  }

  void _aportar(String idParticipante) {
    final resultado = _servicio.registrarAportacion(idParticipante);
    setState(() {});

    final mensaje = switch (resultado) {
      ResultadoAportacion.registrada => 'Aportación registrada.',
      ResultadoAportacion.yaAporto => 'Este participante ya aportó en esta ronda.',
      ResultadoAportacion.participanteInvalido => 'El participante no pertenece a la tanda.',
      ResultadoAportacion.tandaTerminada => 'La tanda ya terminó.',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  void _cerrarRonda() {
    final cierre = _servicio.cerrarRondaYAvanzar();

    if (cierre.resultado == ResultadoCierre.faltanAportaciones) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todavía faltan vecinos por aportar.')),
      );
      return;
    }

    if (cierre.resultado == ResultadoCierre.tandaYaTermino) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La tanda ya terminó.')),
      );
      return;
    }

    setState(() {});
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'beneficiario',
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              title: const Text('¡Turno entregado!'),
              content: Text(
                'Le tocó a ${cierre.beneficiario!.nombre} esta ronda.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalAportado = _tanda.aportacionesRondaActual.length;
    final totalParticipantes = _tanda.participantes.length;
    final terminada = _servicio.haTerminado();
    final progreso = totalParticipantes == 0
        ? 0.0
        : totalAportado / totalParticipantes;

    return Scaffold(
      appBar: AppBar(title: const Text('Tanda Doloreña')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            terminada
                ? 'Tanda finalizada'
                : 'Ronda actual: ${_tanda.turnoActual + 1} de ${_tanda.ordenTurnos.length}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progreso),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: value, minHeight: 10),
            ),
          ),
          const SizedBox(height: 6),
          Text('$totalAportado de $totalParticipantes vecinos ya aportaron'),
          const SizedBox(height: 8),
          Text('Aportación por persona: \$${_tanda.montoAportacion.toStringAsFixed(2)}'),
          const SizedBox(height: 20),
          ..._tanda.participantes.map((participante) {
            final esTurnoActual = !terminada &&
                _tanda.ordenTurnos[_tanda.turnoActual] == participante.id;
            final yaAporto = _tanda.aportacionesRondaActual
                .contains(participante.id);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: esTurnoActual
                    ? Colors.amber.shade100
                    : Colors.grey.shade100,
                border: Border.all(
                  color: esTurnoActual ? Colors.amber : Colors.grey.shade300,
                  width: esTurnoActual ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    participante.yaRecibioTurno
                        ? Icons.check_circle
                        : Icons.person,
                    color: participante.yaRecibioTurno
                        ? Colors.green
                        : Colors.indigo,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          participante.nombre,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (esTurnoActual)
                          const Text(
                            'Turno actual',
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontSize: 12,
                            ),
                          ),
                        if (participante.yaRecibioTurno)
                          const Text(
                            'Ya recibió su turno',
                            style: TextStyle(color: Colors.green, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: (yaAporto || terminada)
                        ? null
                        : () => _aportar(participante.id),
                    child: Text(yaAporto ? 'Aportó' : 'Aportar'),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: terminada ? null : _cerrarRonda,
            icon: const Icon(Icons.emoji_events),
            label: const Text('Cerrar ronda y entregar turno'),
          ),
          if (terminada)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Todos los participantes recibieron su turno. La tanda ha concluido.',
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
