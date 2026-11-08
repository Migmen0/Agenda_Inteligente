
import '../modelos/tarea.dart';
import 'almacenamiento_tareas.dart';
import 'notificaciones_service.dart';

/// Centraliza las operaciones y la persistencia de las tareas.
class GestorTareas {
GestorTareas._();

/// Recupera las tareas guardadas en el teléfono.
static Future<List<Tarea>> cargarTareas() {
return AlmacenamientoTareas.cargarTareas();
}

/// Guarda las tareas en el almacenamiento local.
static Future<bool> guardarTareas(List<Tarea> tareas) {
return AlmacenamientoTareas.guardarTareas(tareas);
}

/// Programa o cancela los recordatorios según el estado de cada tarea.
static Future<void> sincronizarRecordatorios(
List<Tarea> tareas,
) async {
for (final tarea in tareas) {
if (tarea.completada || tarea.hora == null) {
await NotificacionesService.instancia
    .cancelarRecordatorio(tarea.id);
continue;
}

final fechaHora = DateTime(
tarea.fecha.year,
tarea.fecha.month,
tarea.fecha.day,
tarea.hora!.hour,
tarea.hora!.minute,
);

if (fechaHora.isAfter(DateTime.now())) {
await NotificacionesService.instancia
    .programarRecordatorio(
id: tarea.id,
titulo: tarea.titulo,
fechaHora: fechaHora,
);
} else {
await NotificacionesService.instancia
    .cancelarRecordatorio(tarea.id);
}
}
}

/// Cancela el recordatorio de una tarea eliminada.
static Future<void> cancelarRecordatorio(int id) {
return NotificacionesService.instancia
    .cancelarRecordatorio(id);
}
}
