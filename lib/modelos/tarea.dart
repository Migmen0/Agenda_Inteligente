
import 'package:flutter/material.dart';

/// Frecuencia de repetición de una tarea.
enum Recurrencia {
  ninguna,
  diaria,
  semanal,
  mensual,
}

/// Representa una tarea de Mi Agenda Inteligente.
class Tarea {
  Tarea({
    int? id,
    required this.titulo,
    required this.fecha,
    this.hora,
    this.completada = false,
    this.recurrencia = Recurrencia.ninguna,
    int? idSerie,
  })  : id = id ?? _generarId(),
        idSerie = idSerie ?? id;

  static int _ultimoId =
  DateTime.now().microsecondsSinceEpoch.remainder(2000000000);

  static int _generarId() {
    _ultimoId = (_ultimoId + 1) % 2000000000;
    return _ultimoId;
  }

  /// Identificador único de esta ocurrencia.
  final int id;

  /// Identificador compartido por las ocurrencias de una serie.
  /// Si es null, el ID de la propia tarea identifica la serie.
  final int? idSerie;

  String titulo;
  DateTime fecha;
  TimeOfDay? hora;
  bool completada;
  Recurrencia recurrencia;

  /// Identificador efectivo de la serie.
  int get identificadorSerie => idSerie ?? id;

  /// Convierte la tarea a un formato compatible con JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idSerie': idSerie,
      'titulo': titulo,
      'fecha': fecha.toIso8601String(),
      'hora': hora == null ? null : '${hora!.hour}:${hora!.minute}',
      'completada': completada,
      'recurrencia': recurrencia.name,
    };
  }

  /// Recupera tareas guardadas, incluso si pertenecen al formato antiguo.
  factory Tarea.fromJson(Map<String, dynamic> json) {
    TimeOfDay? horaGuardada;

    if (json['hora'] != null) {
      final partes = (json['hora'] as String).split(':');

      horaGuardada = TimeOfDay(
        hour: int.parse(partes[0]),
        minute: int.parse(partes[1]),
      );
    }

    final nombreRecurrencia = json['recurrencia'] as String?;

    final recurrenciaGuardada = Recurrencia.values.firstWhere(
          (valor) => valor.name == nombreRecurrencia,
      orElse: () => Recurrencia.ninguna,
    );

    return Tarea(
      id: (json['id'] as num?)?.toInt(),
      idSerie: (json['idSerie'] as num?)?.toInt(),
      titulo: json['titulo'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      hora: horaGuardada,
      completada: json['completada'] as bool? ?? false,
      recurrencia: recurrenciaGuardada,
    );
  }
}
