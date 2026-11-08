
import 'package:flutter/material.dart';

import '../modelos/tarea.dart';

class DialogoNuevaTarea extends StatefulWidget {
  const DialogoNuevaTarea({super.key, this.tareaInicial});

  final Tarea? tareaInicial;

  @override
  State<DialogoNuevaTarea> createState() => _DialogoNuevaTareaState();
}

class _DialogoNuevaTareaState extends State<DialogoNuevaTarea> {
  late final TextEditingController tituloController;
  late DateTime fechaSeleccionada;
  TimeOfDay? horaSeleccionada;

  bool get editando => widget.tareaInicial != null;

  @override
  void initState() {
    super.initState();

    final tarea = widget.tareaInicial;

    tituloController = TextEditingController(
      text: tarea?.titulo ?? '',
    );

    fechaSeleccionada = DateUtils.dateOnly(
      tarea?.fecha ?? DateTime.now(),
    );

    horaSeleccionada = tarea?.hora;
  }

  @override
  void dispose() {
    tituloController.dispose();
    super.dispose();
  }

  Future<void> seleccionarFecha() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Selecciona la fecha de la tarea',
    );

    if (!mounted || fecha == null) return;

    setState(() {
      fechaSeleccionada = DateUtils.dateOnly(fecha);
    });
  }

  Future<void> seleccionarHora() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final hora = await showTimePicker(
      context: context,
      initialTime: horaSeleccionada ?? TimeOfDay.now(),
    );

    if (!mounted || hora == null) return;

    setState(() {
      horaSeleccionada = hora;
    });
  }

  void cerrarDialogo([Tarea? tarea]) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop(tarea);
  }

  @override
  Widget build(BuildContext context) {
    final fechaTexto =
        '${fechaSeleccionada.day.toString().padLeft(2, '0')}/'
        '${fechaSeleccionada.month.toString().padLeft(2, '0')}/'
        '${fechaSeleccionada.year}';

    return AlertDialog(
      title: Text(editando ? 'Editar tarea' : 'Nueva tarea'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: tituloController,
              autofocus: true,
              maxLength: 100,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: '¿Qué necesitas hacer?',
                hintText: 'Ej. Estudiar para el examen',
                prefixIcon: Icon(Icons.edit_note_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Fecha',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_month_rounded),
              title: Text(fechaTexto),
              trailing: const Icon(Icons.edit_calendar_rounded),
              onTap: seleccionarFecha,
            ),
            const Divider(),
            const Text(
              'Hora (opcional)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time_rounded),
              title: Text(
                horaSeleccionada == null
                    ? 'Sin hora definida'
                    : horaSeleccionada!.format(context),
              ),
              trailing: const Icon(Icons.schedule_rounded),
              onTap: seleccionarHora,
            ),
            if (horaSeleccionada != null)
              TextButton.icon(
                onPressed: () {
                  setState(() => horaSeleccionada = null);
                },
                icon: const Icon(Icons.close_rounded),
                label: const Text('Quitar hora'),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => cerrarDialogo(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final titulo = tituloController.text.trim();

            if (titulo.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Escribe el nombre de la tarea.'),
                ),
              );
              return;
            }

            cerrarDialogo(
              Tarea(
                id: widget.tareaInicial?.id,
                titulo: titulo,
                fecha: fechaSeleccionada,
                hora: horaSeleccionada,
                completada: widget.tareaInicial?.completada ?? false,
              ),
            );
          },
          child: Text(editando ? 'Guardar cambios' : 'Guardar tarea'),
        ),
      ],
    );
  }
}
