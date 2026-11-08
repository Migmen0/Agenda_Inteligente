
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Gestiona las notificaciones locales de Mi Agenda Inteligente.
class NotificacionesService {
  NotificacionesService._();

  static final NotificacionesService instancia =
  NotificacionesService._();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  bool _inicializado = false;
  bool _zonaHorariaInicializada = false;

  /// Inicializa las notificaciones y la zona horaria del teléfono.
  Future<void> inicializar() async {
    if (_inicializado) return;

    const configuracionAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const configuracion = InitializationSettings(
      android: configuracionAndroid,
    );

    await _plugin.initialize(settings: configuracion);

    tz_data.initializeTimeZones();

    final zona = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zona.identifier));

    _zonaHorariaInicializada = true;
    _inicializado = true;
  }

  /// Solicita permiso para mostrar notificaciones en Android.
  Future<bool> solicitarPermiso() async {
    await inicializar();

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android == null) return false;

    final permisoConcedido =
    await android.requestNotificationsPermission();

    return permisoConcedido ?? false;
  }

  /// Programa un recordatorio para una tarea.
  ///
  /// [id] debe ser un identificador entero único y estable de la tarea.
  /// [fechaHora] contiene la fecha y la hora del recordatorio.
  Future<void> programarRecordatorio({
    required int id,
    required String titulo,
    required DateTime fechaHora,
  }) async {
    await inicializar();

    if (!_zonaHorariaInicializada) {
      throw StateError('La zona horaria no está inicializada.');
    }

    // No programar recordatorios para fechas que ya pasaron.
    if (!fechaHora.isAfter(DateTime.now())) {
      await cancelarRecordatorio(id);
      return;
    }

    const detallesAndroid = AndroidNotificationDetails(
      'mi_agenda_recordatorios',
      'Recordatorios de tareas',
      channelDescription:
      'Notificaciones para recordar tareas y actividades.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const detalles = NotificationDetails(
      android: detallesAndroid,
    );

    await _plugin.zonedSchedule(
      id: id,
      title: 'Mi Agenda Inteligente',
      body: titulo,
      scheduledDate: tz.TZDateTime.from(fechaHora, tz.local),
      notificationDetails: detalles,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Cancela el recordatorio de una tarea.
  Future<void> cancelarRecordatorio(int id) async {
    await inicializar();
    await _plugin.cancel(id: id);
  }

  /// Muestra una notificación inmediata de prueba.
  Future<void> mostrarNotificacionPrueba() async {
    await inicializar();

    const detallesAndroid = AndroidNotificationDetails(
      'mi_agenda_recordatorios',
      'Recordatorios de tareas',
      channelDescription:
      'Notificaciones para recordar tareas y actividades.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const detalles = NotificationDetails(
      android: detallesAndroid,
    );

    await _plugin.show(
      id: 1001,
      title: 'Mi Agenda Inteligente',
      body: '¡Las notificaciones están funcionando correctamente!',
      notificationDetails: detalles,
    );
  }
}
