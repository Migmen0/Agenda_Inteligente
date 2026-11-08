
import 'package:flutter/material.dart';

import '../configuracion/tema_app.dart';
import '../modelos/tarea.dart';
import '../componentes/tarjeta_tarea.dart';

class PantallaCalendario extends StatefulWidget {
  const PantallaCalendario({
    super.key,
    required this.tareas,
    required this.fechaTexto,
    required this.mesTexto,
    required this.alCambiarEstado,
    required this.alEliminar,
    required this.alEditar,
  });

  final List<Tarea> tareas;
  final String Function(DateTime) fechaTexto;
  final String Function(DateTime) mesTexto;
  final Future<void> Function(Tarea, bool) alCambiarEstado;
  final Future<void> Function(Tarea) alEliminar;
  final Future<void> Function(Tarea) alEditar;

  @override
  State<PantallaCalendario> createState() => _PantallaCalendarioState();
}

class _PantallaCalendarioState extends State<PantallaCalendario> {
  DateTime fechaSeleccionada = DateUtils.dateOnly(DateTime.now());

  // 0 = día, 1 = semana, 2 = mes.
  int vista = 0;

  static const List<String> _meses = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  static const List<String> _diasSemana = [
    'L',
    'M',
    'X',
    'J',
    'V',
    'S',
    'D',
  ];

  String _nombreMes(DateTime fecha) {
    return _meses[fecha.month - 1];
  }

  DateTime get _lunesSemana {
    return DateUtils.dateOnly(
      fechaSeleccionada.subtract(
        Duration(days: fechaSeleccionada.weekday - 1),
      ),
    );
  }

  DateTime get _domingoSemana {
    return _lunesSemana.add(const Duration(days: 6));
  }

  String _tituloSemana() {
    final lunes = _lunesSemana;
    final domingo = _domingoSemana;

    if (lunes.year == domingo.year && lunes.month == domingo.month) {
      return '${lunes.day}–${domingo.day} de '
          '${_nombreMes(domingo)} de ${domingo.year}';
    }

    if (lunes.year == domingo.year) {
      return '${lunes.day} de ${_nombreMes(lunes)} – '
          '${domingo.day} de ${_nombreMes(domingo)} de ${domingo.year}';
    }

    return '${lunes.day} de ${_nombreMes(lunes)} de ${lunes.year} – '
        '${domingo.day} de ${_nombreMes(domingo)} de ${domingo.year}';
  }

  void cambiarDia(int cantidad) {
    setState(() {
      fechaSeleccionada = DateUtils.dateOnly(
        fechaSeleccionada.add(Duration(days: cantidad)),
      );
    });
  }

  void cambiarMes(int cantidad) {
    setState(() {
      fechaSeleccionada = DateTime(
        fechaSeleccionada.year,
        fechaSeleccionada.month + cantidad,
        1,
      );
    });
  }

  void irAHoy() {
    setState(() {
      fechaSeleccionada = DateUtils.dateOnly(DateTime.now());
    });
  }

  List<Tarea> get tareasSeleccionadas {
    final tareas = widget.tareas.where((tarea) {
      if (vista == 0) {
        return DateUtils.isSameDay(
          tarea.fecha,
          fechaSeleccionada,
        );
      }

      if (vista == 1) {
        final inicio = _lunesSemana;
        final fin = inicio.add(const Duration(days: 7));
        final fechaTarea = DateUtils.dateOnly(tarea.fecha);

        return !fechaTarea.isBefore(inicio) &&
            fechaTarea.isBefore(fin);
      }

      return tarea.fecha.year == fechaSeleccionada.year &&
          tarea.fecha.month == fechaSeleccionada.month;
    }).toList();

    tareas.sort((a, b) {
      final fechaA = DateUtils.dateOnly(a.fecha);
      final fechaB = DateUtils.dateOnly(b.fecha);

      final comparacionFecha = fechaA.compareTo(fechaB);

      if (comparacionFecha != 0) {
        return comparacionFecha;
      }

      if (a.hora == null && b.hora == null) {
        return 0;
      }

      if (a.hora == null) {
        return 1;
      }

      if (b.hora == null) {
        return -1;
      }

      final minutosA = a.hora!.hour * 60 + a.hora!.minute;
      final minutosB = b.hora!.hour * 60 + b.hora!.minute;

      return minutosA.compareTo(minutosB);
    });

    return tareas;
  }

  @override
  Widget build(BuildContext context) {
    final tareasVisibles = tareasSeleccionadas;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
      children: [
        const Text(
          'Calendario',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colorTexto,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Organiza tu tiempo y revisa tus pendientes.',
          style: TextStyle(color: Color(0xFF77758B)),
        ),
        const SizedBox(height: 22),

        // Selector de vistas.
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorBorde),
          ),
          child: Row(
            children: [
              _opcionVista('Día', 0),
              _opcionVista('Semana', 1),
              _opcionVista('Mes', 2),
            ],
          ),
        ),
        const SizedBox(height: 18),

        if (vista == 0) ...[
          filaNavegacion(
            titulo: widget.fechaTexto(fechaSeleccionada),
            anterior: () => cambiarDia(-1),
            siguiente: () => cambiarDia(1),
            hoy: irAHoy,
          ),
          const SizedBox(height: 12),
          tarjetaDiaSeleccionado(),
        ],

        if (vista == 1) ...[
          filaNavegacion(
            titulo: _tituloSemana(),
            anterior: () => cambiarDia(-7),
            siguiente: () => cambiarDia(7),
            hoy: irAHoy,
          ),
          const SizedBox(height: 12),
          selectorSemana(),
        ],

        if (vista == 2) ...[
          filaNavegacion(
            titulo: widget.mesTexto(fechaSeleccionada),
            anterior: () => cambiarMes(-1),
            siguiente: () => cambiarMes(1),
            hoy: irAHoy,
          ),
          const SizedBox(height: 12),
          calendarioMensual(),
        ],

        const SizedBox(height: 26),
        Text(
          vista == 0
              ? 'Tareas del día'
              : vista == 1
              ? 'Tareas de la semana'
              : 'Tareas del mes',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorTexto,
          ),
        ),
        const SizedBox(height: 12),

        if (tareasVisibles.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorBorde),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.event_available_rounded,
                  size: 42,
                  color: Color(0xFFAAA5D5),
                ),
                SizedBox(height: 10),
                Text(
                  'No hay tareas para este período',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorTexto,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Puedes añadir una tarea con el botón inferior.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF77758B)),
                ),
              ],
            ),
          )
        else
          ...tareasVisibles.map(
                (tarea) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (vista != 0)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 6,
                      top: 4,
                    ),
                    child: Text(
                      widget.fechaTexto(tarea.fecha),
                      style: const TextStyle(
                        color: colorPrincipal,
                        fontWeight: FontWeight.w600,
                      ),
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
            ),
          ),
      ],
    );
  }

  Widget _opcionVista(String texto, int indice) {
    final seleccionada = vista == indice;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            vista = indice;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: seleccionada ? colorPrincipal : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: seleccionada ? Colors.white : colorTexto,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget filaNavegacion({
    required String titulo,
    required VoidCallback anterior,
    required VoidCallback siguiente,
    required VoidCallback hoy,
  }) {
    return Row(
      children: [
        IconButton(
          onPressed: anterior,
          icon: const Icon(Icons.chevron_left_rounded),
          tooltip: 'Anterior',
        ),
        Expanded(
          child: Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: colorTexto,
            ),
          ),
        ),
        IconButton(
          onPressed: siguiente,
          icon: const Icon(Icons.chevron_right_rounded),
          tooltip: 'Siguiente',
        ),
        TextButton(
          onPressed: hoy,
          child: const Text('Hoy'),
        ),
      ],
    );
  }

  Widget tarjetaDiaSeleccionado() {
    final cantidad = widget.tareas
        .where(
          (tarea) => DateUtils.isSameDay(
        tarea.fecha,
        fechaSeleccionada,
      ),
    )
        .length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7568E8),
            Color(0xFF5143B8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.today_rounded,
            color: Colors.white,
            size: 36,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              widget.fechaTexto(fechaSeleccionada),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$cantidad ${cantidad == 1 ? 'tarea' : 'tareas'}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget selectorSemana() {
    final lunes = _lunesSemana;

    return Row(
      children: List.generate(7, (indice) {
        final fecha = DateUtils.dateOnly(
          lunes.add(Duration(days: indice)),
        );

        final seleccionada = DateUtils.isSameDay(
          fecha,
          fechaSeleccionada,
        );

        final tieneTareas = widget.tareas.any(
              (tarea) => DateUtils.isSameDay(tarea.fecha, fecha),
        );

        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                fechaSeleccionada = fecha;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: seleccionada ? colorPrincipal : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: seleccionada ? colorPrincipal : colorBorde,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _diasSemana[indice],
                    style: TextStyle(
                      fontSize: 12,
                      color: seleccionada
                          ? Colors.white70
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${fecha.day}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: seleccionada ? Colors.white : colorTexto,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: tieneTareas
                          ? seleccionada
                          ? Colors.white
                          : colorPrincipal
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget calendarioMensual() {
    final primerDia = DateTime(
      fechaSeleccionada.year,
      fechaSeleccionada.month,
      1,
    );

    final diasEnMes = DateTime(
      fechaSeleccionada.year,
      fechaSeleccionada.month + 1,
      0,
    ).day;

    // DateTime.weekday: lunes = 1; domingo = 7.
    final espaciosIniciales = primerDia.weekday - 1;

    final totalCeldas =
        ((espaciosIniciales + diasEnMes + 6) ~/ 7) * 7;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorBorde),
      ),
      child: Column(
        children: [
          Row(
            children: _diasSemana.map((dia) {
              return Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      dia,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF77758B),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCeldas,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, indice) {
              final numeroDia = indice - espaciosIniciales + 1;

              if (numeroDia < 1 || numeroDia > diasEnMes) {
                return const SizedBox.shrink();
              }

              final fecha = DateTime(
                fechaSeleccionada.year,
                fechaSeleccionada.month,
                numeroDia,
              );

              final seleccionada = DateUtils.isSameDay(
                fecha,
                fechaSeleccionada,
              );

              final esHoy = DateUtils.isSameDay(
                fecha,
                DateTime.now(),
              );

              final tieneTareas = widget.tareas.any(
                    (tarea) => DateUtils.isSameDay(tarea.fecha, fecha),
              );

              return GestureDetector(
                onTap: () {
                  setState(() {
                    fechaSeleccionada = fecha;
                    vista = 0;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: seleccionada
                        ? colorPrincipal
                        : esHoy
                        ? const Color(0xFFEAE7FF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: esHoy && !seleccionada
                        ? Border.all(color: colorPrincipal)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$numeroDia',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: seleccionada ? Colors.white : colorTexto,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: tieneTareas
                              ? seleccionada
                              ? Colors.white
                              : colorPrincipal
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
