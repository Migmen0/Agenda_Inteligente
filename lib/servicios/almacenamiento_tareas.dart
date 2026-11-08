
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../configuracion/tema_app.dart';
import '../modelos/tarea.dart';

class AlmacenamientoTareas {
  AlmacenamientoTareas._();

  static Future<List<Tarea>> cargarTareas() async {
    final preferencias = await SharedPreferences.getInstance();
    final datos = preferencias.getString(claveTareas);

    if (datos == null || datos.isEmpty) {
      return [];
    }

    final List<dynamic> lista = jsonDecode(datos) as List<dynamic>;

    return lista.map((elemento) {
      return Tarea.fromJson(
        Map<String, dynamic>.from(elemento as Map),
      );
    }).toList();
  }

  static Future<bool> guardarTareas(List<Tarea> tareas) async {
    final preferencias = await SharedPreferences.getInstance();

    final datos = jsonEncode(
      tareas.map((tarea) => tarea.toJson()).toList(),
    );

    return preferencias.setString(claveTareas, datos);
  }
}
