
import 'package:flutter/material.dart';

const colorPrincipal = Color(0xFF6658D3);
const colorFondo = Color(0xFFF7F7FC);
const colorTexto = Color(0xFF25233A);
const colorBorde = Color(0xFFECEAF5);

const String claveTareas = 'mi_agenda_tareas';

ThemeData crearTemaApp() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: colorFondo,
    colorScheme: ColorScheme.fromSeed(
      seedColor: colorPrincipal,
    ),
    fontFamily: 'Roboto',
  );
}
