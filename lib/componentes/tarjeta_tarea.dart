
import 'package:flutter/material.dart';

import '../configuracion/tema_app.dart';
import '../modelos/tarea.dart';

class TarjetaTarea extends StatelessWidget {
  const TarjetaTarea({
    super.key,
    required this.tarea,
    required this.alCambiarEstado,
    required this.alEliminar,
    this.alEditar,
  });

  final Tarea tarea;
  final ValueChanged<bool> alCambiarEstado;
  final VoidCallback alEliminar;
  final VoidCallback? alEditar;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorBorde),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 8, right: 4),
        leading: Checkbox(
          value: tarea.completada,
          activeColor: const Color(0xFF269B75),
          onChanged: (valor) {
            if (valor != null) alCambiarEstado(valor);
          },
        ),
        title: Text(
          tarea.titulo,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: tarea.completada
                ? TextDecoration.lineThrough
                : null,
            color: tarea.completada ? Colors.grey : colorTexto,
          ),
        ),
        subtitle: Text(
          tarea.hora == null
              ? 'Sin hora definida'
              : 'Hora: ${tarea.hora!.format(context)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (alEditar != null)
              IconButton(
                tooltip: 'Editar tarea',
                icon: const Icon(
                  Icons.edit_outlined,
                  color: colorPrincipal,
                ),
                onPressed: alEditar,
              ),
            IconButton(
              tooltip: 'Eliminar tarea',
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFB85C68),
              ),
              onPressed: alEliminar,
            ),
          ],
        ),
      ),
    );
  }
}
