import 'package:flutter/material.dart';

import '../configuracion/tema_app.dart';
import '../modelos/tarea.dart';
import '../componentes/tarjeta_tarea.dart';

class PantallaTareas extends StatefulWidget {
  const PantallaTareas({
    super.key,
    required this.tareas,
    required this.fechaTexto,
    required this.alCambiarEstado,
    required this.alEliminar,
    required this.alEditar,
  });

  final List<Tarea> tareas;
  final String Function(DateTime) fechaTexto;
  final Future<void> Function(Tarea, bool) alCambiarEstado;
  final Future<void> Function(Tarea) alEliminar;
  final Future<void> Function(Tarea) alEditar;

  @override
  State<PantallaTareas> createState() => _PantallaTareasState();
}

class _PantallaTareasState extends State<PantallaTareas> {
  // 0 = todas, 1 = pendientes, 2 = completadas.
  int filtroSeleccionado = 0;

  List<Tarea> get tareasFiltradas {
    final resultado = widget.tareas.where((tarea) {
      if (filtroSeleccionado == 1) {
        return !tarea.completada;
      }

      if (filtroSeleccionado == 2) {
        return tarea.completada;
      }

      return true;
    }).toList();

    resultado.sort((a, b) {
      final fechaA = DateUtils.dateOnly(a.fecha);
      final fechaB = DateUtils.dateOnly(b.fecha);

      final comparacionFecha = fechaA.compareTo(fechaB);
      if (comparacionFecha != 0) return comparacionFecha;

      if (a.hora == null && b.hora == null) return 0;
      if (a.hora == null) return 1;
      if (b.hora == null) return -1;

      final minutosA = a.hora!.hour * 60 + a.hora!.minute;
      final minutosB = b.hora!.hour * 60 + b.hora!.minute;

      return minutosA.compareTo(minutosB);
    });

    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    final hoy = DateUtils.dateOnly(DateTime.now());

    final pendientes =
        widget.tareas.where((tarea) => !tarea.completada).length;

    final completadas =
        widget.tareas.where((tarea) => tarea.completada).length;

    final atrasadas = widget.tareas.where((tarea) {
      return !tarea.completada &&
          DateUtils.dateOnly(tarea.fecha).isBefore(hoy);
    }).length;

    final visibles = tareasFiltradas;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
      children: [
        const Text(
          'Mis tareas',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colorTexto,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Todo lo que tienes por hacer, en un solo lugar.',
          style: TextStyle(color: Color(0xFF77758B)),
        ),
        const SizedBox(height: 22),

        Row(
          children: [
            Expanded(
              child: _resumenTareas(
                titulo: 'Pendientes',
                cantidad: pendientes,
                icono: Icons.pending_actions_rounded,
                color: colorPrincipal,
                fondo: const Color(0xFFEAE7FF),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _resumenTareas(
                titulo: 'Completadas',
                cantidad: completadas,
                icono: Icons.task_alt_rounded,
                color: const Color(0xFF269B75),
                fondo: const Color(0xFFDFF7ED),
              ),
            ),
          ],
        ),

        if (atrasadas > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF3D0D0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFB85C68),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tienes $atrasadas '
                        '${atrasadas == 1 ? 'tarea atrasada' : 'tareas atrasadas'}.',
                    style: const TextStyle(
                      color: Color(0xFF9E414D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 26),
        const Text(
          'Filtrar tareas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorTexto,
          ),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _filtro('Todas', 0),
            _filtro('Pendientes', 1),
            _filtro('Completadas', 2),
          ],
        ),

        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Listado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorTexto,
              ),
            ),
            Text(
              '${visibles.length} '
                  '${visibles.length == 1 ? 'tarea' : 'tareas'}',
              style: const TextStyle(color: Color(0xFF77758B)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (visibles.isEmpty)
          Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorBorde),
            ),
            child: Column(
              children: [
                Icon(
                  filtroSeleccionado == 2
                      ? Icons.task_alt_rounded
                      : Icons.event_note_rounded,
                  size: 48,
                  color: const Color(0xFFAAA5D5),
                ),
                const SizedBox(height: 12),
                Text(
                  filtroSeleccionado == 1
                      ? 'No tienes tareas pendientes'
                      : filtroSeleccionado == 2
                      ? 'Todavía no hay tareas completadas'
                      : 'Todavía no has creado tareas',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorTexto,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Las tareas que crees aparecerán aquí.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF77758B)),
                ),
              ],
            ),
          )
        else
          ...visibles.map((tarea) {
            final fechaTarea = DateUtils.dateOnly(tarea.fecha);
            final esAtrasada =
                !tarea.completada && fechaTarea.isBefore(hoy);
            final esHoy = DateUtils.isSameDay(tarea.fecha, hoy);

            final etiquetaFecha = esHoy
                ? 'Hoy'
                : esAtrasada
                ? 'Atrasada'
                : widget.fechaTexto(tarea.fecha);

            final colorFecha = esAtrasada
                ? const Color(0xFFB85C68)
                : esHoy
                ? colorPrincipal
                : const Color(0xFF77758B);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 4,
                    bottom: 6,
                    top: 4,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        esAtrasada
                            ? Icons.warning_amber_rounded
                            : esHoy
                            ? Icons.today_rounded
                            : Icons.calendar_today_rounded,
                        size: 15,
                        color: colorFecha,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        etiquetaFecha,
                        style: TextStyle(
                          color: colorFecha,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      if (tarea.hora != null) ...[
                        const SizedBox(width: 10),
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: colorFecha,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${tarea.hora!.hour.toString().padLeft(2, '0')}:'
                              '${tarea.hora!.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: colorFecha,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                TarjetaTarea(
                  key: ObjectKey(tarea),
                  tarea: tarea,
                  alCambiarEstado: (valor) {
                    widget.alCambiarEstado(tarea, valor);
                  },
                  alEliminar: () {
                    widget.alEliminar(tarea);
                  },
                  alEditar: () {
                    widget.alEditar(tarea);
                  },
                ),
              ],
            );
          }),
      ],
    );
  }

  Widget _filtro(String texto, int indice) {
    final seleccionado = filtroSeleccionado == indice;

    return ChoiceChip(
      label: Text(texto),
      selected: seleccionado,
      selectedColor: const Color(0xFFEAE7FF),
      labelStyle: TextStyle(
        color: seleccionado ? colorPrincipal : colorTexto,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: seleccionado ? colorPrincipal : colorBorde,
      ),
      onSelected: (_) {
        setState(() {
          filtroSeleccionado = indice;
        });
      },
    );
  }

  Widget _resumenTareas({
    required String titulo,
    required int cantidad,
    required IconData icono,
    required Color color,
    required Color fondo,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorBorde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: fondo,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, color: color, size: 21),
          ),
          const SizedBox(height: 12),
          Text(
            '$cantidad',
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: colorTexto,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF77758B),
            ),
          ),
        ],
      ),
    );
  }
}
