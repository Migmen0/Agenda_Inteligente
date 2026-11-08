
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../configuracion/tema_app.dart';

// ============================================================
// PANTALLA DE LISTAS DE COMPRAS Y PENDIENTES
// ============================================================

class PantallaListas extends StatefulWidget {
  const PantallaListas({super.key});

  @override
  State<PantallaListas> createState() => _PantallaListasState();
}

class _PantallaListasState extends State<PantallaListas> {
  static const String claveListas = 'mi_agenda_listas';

  final List<Map<String, dynamic>> listas = [];

  bool cargando = true;
  bool guardando = false;

  final TextEditingController controladorNuevaLista =
  TextEditingController();

  final TextEditingController controladorElemento =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarListas();
  }

  @override
  void dispose() {
    controladorNuevaLista.dispose();
    controladorElemento.dispose();
    super.dispose();
  }

  // ==========================================================
  // CARGAR LISTAS
  // ==========================================================

  Future<void> cargarListas() async {
    try {
      final preferencias = await SharedPreferences.getInstance();
      final contenido = preferencias.getString(claveListas);

      if (contenido != null && contenido.isNotEmpty) {
        final datos = jsonDecode(contenido);

        if (datos is List) {
          final listasRecuperadas = <Map<String, dynamic>>[];

          for (final elemento in datos) {
            if (elemento is! Map) continue;

            final lista = Map<String, dynamic>.from(elemento);
            final elementosOriginales = lista['elementos'];

            final elementos = <Map<String, dynamic>>[];

            if (elementosOriginales is List) {
              for (final item in elementosOriginales) {
                if (item is! Map) continue;

                final mapaItem = Map<String, dynamic>.from(item);

                if (mapaItem['nombre'] is! String) continue;

                elementos.add({
                  'nombre': mapaItem['nombre'],
                  'completado': mapaItem['completado'] == true,
                });
              }
            }

            final nombre = lista['nombre'];

            if (nombre is! String || nombre.trim().isEmpty) {
              continue;
            }

            listasRecuperadas.add({
              'id': lista['id']?.toString() ??
                  DateTime.now().microsecondsSinceEpoch.toString(),
              'nombre': nombre,
              'elementos': elementos,
            });
          }

          listas
            ..clear()
            ..addAll(listasRecuperadas);
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudieron leer las listas guardadas.',
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

  // ==========================================================
  // GUARDAR LISTAS
  // ==========================================================

  Future<bool> guardarListas() async {
    if (guardando) return false;

    guardando = true;

    try {
      final preferencias = await SharedPreferences.getInstance();

      final contenido = jsonEncode(listas);

      final guardado = await preferencias.setString(
        claveListas,
        contenido,
      );

      if (!guardado && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudieron guardar los cambios.'),
          ),
        );
      }

      return guardado;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ocurrió un error al guardar las listas.'),
          ),
        );
      }

      return false;
    } finally {
      guardando = false;
    }
  }

  // ==========================================================
  // CREAR LISTA
  // ==========================================================

  Future<void> crearLista() async {
    controladorNuevaLista.clear();

    final nombre = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nueva lista'),
          content: TextField(
            controller: controladorNuevaLista,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 80,
            decoration: const InputDecoration(
              hintText: 'Ej. Mercado de la semana',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (valor) {
              if (valor.trim().isNotEmpty) {
                Navigator.pop(context, valor.trim());
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final valor = controladorNuevaLista.text.trim();

                if (valor.isNotEmpty) {
                  Navigator.pop(context, valor);
                }
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );

    if (nombre == null || nombre.trim().isEmpty || !mounted) {
      return;
    }

    setState(() {
      listas.insert(0, {
        'id': DateTime.now().microsecondsSinceEpoch.toString(),
        'nombre': nombre.trim(),
        'elementos': <Map<String, dynamic>>[],
      });
    });

    await guardarListas();
  }

  // ==========================================================
  // AGREGAR ELEMENTO
  // ==========================================================

  Future<void> agregarElemento(int indiceLista) async {
    if (indiceLista < 0 || indiceLista >= listas.length) return;

    final idLista = listas[indiceLista]['id'];

    controladorElemento.clear();

    final nombre = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar elemento'),
          content: TextField(
            controller: controladorElemento,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 120,
            decoration: const InputDecoration(
              hintText: 'Ej. Leche, arroz, cuaderno...',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (valor) {
              if (valor.trim().isNotEmpty) {
                Navigator.pop(context, valor.trim());
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final valor = controladorElemento.text.trim();

                if (valor.isNotEmpty) {
                  Navigator.pop(context, valor);
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );

    if (nombre == null || nombre.trim().isEmpty || !mounted) return;

    final indiceActual = listas.indexWhere(
          (lista) => lista['id'] == idLista,
    );

    if (indiceActual == -1) return;

    setState(() {
      (listas[indiceActual]['elementos'] as List).add({
        'nombre': nombre.trim(),
        'completado': false,
      });
    });

    await guardarListas();
  }

  // ==========================================================
  // MARCAR ELEMENTO
  // ==========================================================

  Future<void> cambiarElemento(
      int indiceLista,
      int indiceElemento,
      bool? valor,
      ) async {
    if (indiceLista < 0 || indiceLista >= listas.length) return;

    final elementos = listas[indiceLista]['elementos'] as List;

    if (indiceElemento < 0 || indiceElemento >= elementos.length) {
      return;
    }

    setState(() {
      elementos[indiceElemento]['completado'] = valor ?? false;
    });

    await guardarListas();
  }

  // ==========================================================
  // ELIMINAR ELEMENTO
  // ==========================================================

  Future<void> eliminarElemento(
      int indiceLista,
      int indiceElemento,
      ) async {
    if (indiceLista < 0 || indiceLista >= listas.length) return;

    final elementos = listas[indiceLista]['elementos'] as List;

    if (indiceElemento < 0 || indiceElemento >= elementos.length) {
      return;
    }

    setState(() {
      elementos.removeAt(indiceElemento);
    });

    await guardarListas();
  }

  // ==========================================================
  // ELIMINAR LISTA
  // ==========================================================

  Future<void> eliminarLista(int indiceLista) async {
    if (indiceLista < 0 || indiceLista >= listas.length) return;

    final idLista = listas[indiceLista]['id'];
    final nombreLista = listas[indiceLista]['nombre'] as String;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar lista'),
        content: Text(
          '¿Quieres eliminar "$nombreLista" y todos sus elementos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    final indiceActual = listas.indexWhere(
          (lista) => lista['id'] == idLista,
    );

    if (indiceActual == -1) return;

    setState(() {
      listas.removeAt(indiceActual);
    });

    await guardarListas();
  }

  // ==========================================================
  // INTERFAZ
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      body: SafeArea(
        child: cargando
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mis listas',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colorTexto,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Organiza tus compras y pendientes.',
                        style: TextStyle(
                          color: Color(0xFF77758B),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filled(
                  onPressed: crearLista,
                  tooltip: 'Crear lista',
                  icon: const Icon(Icons.add_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: colorPrincipal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (listas.isEmpty)
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colorBorde),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.shopping_basket_rounded,
                      size: 58,
                      color: colorPrincipal,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Empieza con tu primera lista',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: colorTexto,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Crea una lista de compras, estudio '
                          'o cualquier cosa que necesites recordar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF77758B),
                      ),
                    ),
                  ],
                ),
              ),
            ...List.generate(listas.length, (indiceLista) {
              final lista = listas[indiceLista];
              final elementos = lista['elementos'] as List;

              final completados = elementos
                  .where((elemento) =>
              elemento['completado'] == true)
                  .length;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorBorde),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorPrincipal.withValues(
                              alpha: 0.10,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.checklist_rounded,
                            color: colorPrincipal,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                lista['nombre'] as String,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: colorTexto,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$completados de '
                                    '${elementos.length} completados',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF77758B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Eliminar lista',
                          onPressed: () =>
                              eliminarLista(indiceLista),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                    if (elementos.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: completados / elementos.length,
                          minHeight: 5,
                          backgroundColor: colorBorde,
                          color: colorPrincipal,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    ...List.generate(elementos.length, (indice) {
                      final elemento = elementos[indice];

                      return Row(
                        children: [
                          Checkbox(
                            value: elemento['completado'] == true,
                            activeColor: colorPrincipal,
                            onChanged: (valor) => cambiarElemento(
                              indiceLista,
                              indice,
                              valor,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              elemento['nombre'] as String,
                              style: TextStyle(
                                color: colorTexto,
                                decoration:
                                elemento['completado'] == true
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Eliminar elemento',
                            onPressed: () => eliminarElemento(
                              indiceLista,
                              indice,
                            ),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: Color(0xFF77758B),
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => agregarElemento(indiceLista),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Agregar elemento'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorPrincipal,
                        side: const BorderSide(color: colorBorde),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
