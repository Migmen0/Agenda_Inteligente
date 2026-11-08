import 'package:flutter/material.dart';

import 'configuracion/tema_app.dart';
import 'modelos/tarea.dart';
import 'servicios/gestor_tareas.dart';
import 'servicios/notificaciones_service.dart';
import 'componentes/dialogo_nueva_tarea.dart';
import 'pantallas/pantalla_calendario.dart';
import 'pantallas/pantalla_inicio.dart';
import 'pantallas/pantalla_tareas.dart';
import 'pantallas/pantalla_listas.dart';

void main() async {
WidgetsFlutterBinding.ensureInitialized();

await NotificacionesService.instancia.inicializar();

runApp(const MiAgendaApp());
}

class MiAgendaApp extends StatelessWidget {
const MiAgendaApp({super.key});

@override
Widget build(BuildContext context) {
return MaterialApp(
debugShowCheckedModeBanner: false,
title: 'Mi Agenda Inteligente',
theme: crearTemaApp(),
home: const PantallaInicio(),
);
}
}

// ============================================================
// PANTALLA PRINCIPAL Y NAVEGACIÓN
// ============================================================

class PantallaInicio extends StatefulWidget {
const PantallaInicio({super.key});

@override
State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
final List<Tarea> tareas = [];

bool cargando = true;
int indiceSeleccionado = 0;


@override
void initState() {
  super.initState();

  cargarTareas();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    NotificacionesService.instancia.solicitarPermiso();
  });
}



// Recuperar las tareas guardadas y sincronizar sus recordatorios.
Future<void> cargarTareas() async {
try {
final tareasGuardadas = await GestorTareas.cargarTareas();

if (!mounted) return;

setState(() {
tareas
..clear()
..addAll(tareasGuardadas);
});

await sincronizarRecordatorios();
} catch (error) {
if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'No se pudieron recuperar las tareas guardadas.',
),
),
);
}
} finally {
if (mounted) {
setState(() => cargando = false);
}
}
}

// Sincronizar los recordatorios mediante el gestor.
Future<void> sincronizarRecordatorios() async {
await GestorTareas.sincronizarRecordatorios(tareas);
}

// Guardar todas las tareas.
Future<void> guardarTareas() async {
try {
final guardado = await GestorTareas.guardarTareas(tareas);

if (!guardado && mounted) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('No se pudieron guardar los cambios.'),
),
);
}
} catch (error) {
if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Ocurrió un error al guardar las tareas.',
),
),
);
}
}
}

// Obtener las tareas correspondientes al día actual.
List<Tarea> get tareasDeHoy {
final hoy = DateTime.now();

return tareas
    .where((tarea) => DateUtils.isSameDay(tarea.fecha, hoy))
    .toList()
..sort(compararHoras);
}

// Ordenar las tareas por hora.
int compararHoras(Tarea a, Tarea b) {
if (a.hora == null && b.hora == null) return 0;
if (a.hora == null) return 1;
if (b.hora == null) return -1;

final minutosA = a.hora!.hour * 60 + a.hora!.minute;
final minutosB = b.hora!.hour * 60 + b.hora!.minute;

return minutosA.compareTo(minutosB);
}

// Crear una tarea nueva.
Future<void> agregarTarea() async {
final nuevaTarea = await showDialog<Tarea>(
context: context,
builder: (_) => const DialogoNuevaTarea(),
);

if (!mounted || nuevaTarea == null) return;

setState(() {
tareas.add(nuevaTarea);
});

await guardarTareas();
await sincronizarRecordatorios();

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Tarea creada correctamente.'),
),
);
}

// Editar una tarea existente.
Future<void> editarTarea(Tarea tarea) async {
final tareaEditada = await showDialog<Tarea>(
context: context,
builder: (_) => DialogoNuevaTarea(
tareaInicial: tarea,
),
);

if (!mounted || tareaEditada == null) return;

setState(() {
tarea.titulo = tareaEditada.titulo;
tarea.fecha = tareaEditada.fecha;
tarea.hora = tareaEditada.hora;
});

await guardarTareas();
await sincronizarRecordatorios();

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Tarea actualizada correctamente.'),
),
);
}

// Marcar una tarea como completada o pendiente.
Future<void> cambiarEstado(
Tarea tarea,
bool completada,
) async {
setState(() {
tarea.completada = completada;
});

await guardarTareas();
await sincronizarRecordatorios();
}

// Confirmar y eliminar una tarea.
Future<void> confirmarEliminar(Tarea tarea) async {
final eliminar = await showDialog<bool>(
context: context,
builder: (dialogContext) => AlertDialog(
title: const Text('Eliminar tarea'),
content: Text(
'¿Quieres eliminar "${tarea.titulo}"?',
),
actions: [
TextButton(
onPressed: () =>
Navigator.of(dialogContext).pop(false),
child: const Text('Cancelar'),
),
FilledButton(
onPressed: () =>
Navigator.of(dialogContext).pop(true),
child: const Text('Eliminar'),
),
],
),
);

if (eliminar != true || !mounted) return;

setState(() {
tareas.remove(tarea);
});

await GestorTareas.cancelarRecordatorio(tarea.id);
await guardarTareas();

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Tarea eliminada.'),
),
);
}

// Formatear una fecha en español.
String fechaTexto(DateTime fecha) {
const dias = [
'lunes',
'martes',
'miércoles',
'jueves',
'viernes',
'sábado',
'domingo',
];

const meses = [
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

return '${dias[fecha.weekday - 1]}, ${fecha.day} de '
'${meses[fecha.month - 1]}';
}

// Formatear el nombre del mes y el año.
String mesTexto(DateTime fecha) {
const meses = [
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

return '${meses[fecha.month - 1][0].toUpperCase()}'
'${meses[fecha.month - 1].substring(1)} ${fecha.year}';
}

@override
Widget build(BuildContext context) {
if (cargando) {
return const Scaffold(
body: Center(
child: CircularProgressIndicator(
color: colorPrincipal,
),
),
);
}

return Scaffold(
body: SafeArea(
child: IndexedStack(
index: indiceSeleccionado,
children: [
PantallaInicioContenido(
tareasDeHoy: tareasDeHoy,
fechaTexto: fechaTexto,
alCambiarEstado: cambiarEstado,
alEliminar: confirmarEliminar,
alEditar: editarTarea,
),
PantallaTareas(
tareas: tareas,
fechaTexto: fechaTexto,
alCambiarEstado: cambiarEstado,
alEliminar: confirmarEliminar,
alEditar: editarTarea,
),
PantallaCalendario(
tareas: tareas,
fechaTexto: fechaTexto,
mesTexto: mesTexto,
alCambiarEstado: cambiarEstado,
alEliminar: confirmarEliminar,
alEditar: editarTarea,
),
const PantallaListas(),
],
),
),
floatingActionButton: indiceSeleccionado == 3
? null
    : FloatingActionButton.extended(
onPressed: agregarTarea,
backgroundColor: colorPrincipal,
foregroundColor: Colors.white,
icon: const Icon(Icons.add_rounded),
label: const Text('Nueva tarea'),
),
bottomNavigationBar: NavigationBar(
selectedIndex: indiceSeleccionado,
onDestinationSelected: (indice) {
setState(() {
indiceSeleccionado = indice;
});
},
backgroundColor: Colors.white,
indicatorColor: const Color(0xFFEAE7FF),
destinations: const [
NavigationDestination(
icon: Icon(Icons.home_outlined),
selectedIcon: Icon(Icons.home_rounded),
label: 'Inicio',
),
NavigationDestination(
icon: Icon(Icons.checklist_outlined),
selectedIcon: Icon(Icons.checklist_rounded),
label: 'Tareas',
),
NavigationDestination(
icon: Icon(Icons.calendar_month_outlined),
selectedIcon: Icon(Icons.calendar_month_rounded),
label: 'Calendario',
),
NavigationDestination(
icon: Icon(Icons.shopping_basket_outlined),
selectedIcon: Icon(Icons.shopping_basket_rounded),
label: 'Listas',
),
],
),
);
}
}
