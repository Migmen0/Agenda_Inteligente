
import 'package:flutter/material.dart';

import '../configuracion/tema_app.dart';
import '../modelos/tarea.dart';
import '../componentes/tarjeta_tarea.dart';

class PantallaInicioContenido extends StatelessWidget {
  const PantallaInicioContenido({
    super.key,
    required this.tareasDeHoy,
    required this.fechaTexto,
    required this.alCambiarEstado,
    required this.alEliminar,
    required this.alEditar,
  });

  final List<Tarea> tareasDeHoy;
  final String Function(DateTime fecha) fechaTexto;
  final void Function(Tarea tarea, bool completada) alCambiarEstado;
  final Future<void> Function(Tarea tarea) alEliminar;
  final Future<void> Function(Tarea tarea) alEditar;

  @override
  Widget build(BuildContext context) {
    final pendientes = tareasDeHoy.where((t) => !t.completada).length;
    final completadas = tareasDeHoy.where((t) => t.completada).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 100),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAE7FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: colorPrincipal,
                size: 30,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MI AGENDA',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                      color: colorPrincipal,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tu día, bajo control',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorTexto,
                    ),
                  ),
                ],
              ),
            ),
            const CircleAvatar(
              backgroundColor: Color(0xFFEAE7FF),
              child: Icon(
                Icons.person_outline_rounded,
                color: colorPrincipal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7568E8), Color(0xFF5143B8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.wb_sunny_outlined,
                color: Colors.white,
                size: 30,
              ),
              const SizedBox(height: 16),
              const Text(
                '¡Hola!',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 4),
              const Text(
                '¿Qué vamos a lograr hoy?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                fechaTexto(DateTime.now()),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Text(
                'Organiza tus pendientes y avanza a tu ritmo.',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Resumen de hoy',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorTexto,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _TarjetaResumen(
                icono: Icons.check_circle_outline_rounded,
                titulo: 'Pendientes',
                cantidad: '$pendientes',
                color: colorPrincipal,
                fondo: const Color(0xFFEAE7FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TarjetaResumen(
                icono: Icons.task_alt_rounded,
                titulo: 'Completadas',
                cantidad: '$completadas',
                color: const Color(0xFF269B75),
                fondo: const Color(0xFFDFF7ED),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mis tareas de hoy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorTexto,
              ),
            ),
            Text('${tareasDeHoy.length}'),
          ],
        ),
        const SizedBox(height: 12),
        if (tareasDeHoy.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: colorBorde),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.event_note_rounded,
                  size: 48,
                  color: Color(0xFFAAA5D5),
                ),
                SizedBox(height: 12),
                Text(
                  'Todo comienza con una tarea',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colorTexto,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Pulsa «Nueva tarea» para organizar tu día.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF77758B),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        else
          ...tareasDeHoy.map(
                (tarea) => TarjetaTarea(
              key: ObjectKey(tarea),
              tarea: tarea,
              alCambiarEstado: (valor) =>
                  alCambiarEstado(tarea, valor),
              alEliminar: () => alEliminar(tarea),
              alEditar: () => alEditar(tarea),
            ),
          ),
      ],
    );
  }
}

class _TarjetaResumen extends StatelessWidget {
  const _TarjetaResumen({
    required this.icono,
    required this.titulo,
    required this.cantidad,
    required this.color,
    required this.fondo,
  });

  final IconData icono;
  final String titulo;
  final String cantidad;
  final Color color;
  final Color fondo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorBorde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: fondo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, color: color, size: 23),
          ),
          const SizedBox(height: 16),
          Text(
            cantidad,
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: colorTexto,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF77758B),
            ),
          ),
        ],
      ),
    );
  }
}
