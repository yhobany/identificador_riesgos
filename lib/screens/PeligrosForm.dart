import 'package:flutter/material.dart';
// Importaciones de paquete corregidas para Android Studio
import 'package:identificador_riesgos/constants.dart';
import 'package:identificador_riesgos/models/permiso_data.dart';

class PeligrosForm extends StatefulWidget {
  @override
  _PeligrosFormState createState() => _PeligrosFormState();
}

class _PeligrosFormState extends State<PeligrosForm> {
  final _formKey = GlobalKey<FormState>();
  late PermisoData _data;
  bool _initialized = false;

  Set<String> _categoriasInvalidas = {};

  final List<String> categorias = peligrosPorCategoria.keys.toList();

  Map<String, String?> aplicaCategoria = {};
  Map<String, List<String>> peligroSeleccionado = {};
  Map<String, List<String>> riesgosSeleccionados = {};
  Map<String, List<String>> medidasSeleccionadas = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)!.settings.arguments as PermisoData;
      _data = args;
      setState(() {
        aplicaCategoria = Map.from(_data.aplicaCategoria);
        peligroSeleccionado = Map.from(_data.peligroSeleccionado);
        riesgosSeleccionados = Map.from(_data.riesgosSeleccionados);
        medidasSeleccionadas = Map.from(_data.medidasSeleccionadas);
      });
      _initialized = true;
    }
  }

  Widget buildCheckboxList(List<String> items, List<String> selectedItems,
      Function(String, bool) onChanged) {
    return Column(
      children: items.map((item) {
        return CheckboxListTile(
          title: Text(item),
          value: selectedItems.contains(item),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                selectedItems.add(item);
              } else {
                selectedItems.remove(item);
              }
              onChanged(item, value!);
            });
          },
        );
      }).toList(),
    );
  }

  Widget buildCategoria(String categoria) {
    final bool isCategoriaInvalid = _categoriasInvalidas.contains(categoria);

    bool sonPeligrosInvalidos = false;
    bool sonRiesgosInvalidos = false;
    bool sonMedidasInvalidas = false;

    if (aplicaCategoria[categoria] == 'Sí') {
      sonPeligrosInvalidos = (peligroSeleccionado[categoria] ?? []).isEmpty;
      sonRiesgosInvalidos = (riesgosSeleccionados[categoria] ?? []).isEmpty;
      sonMedidasInvalidas = (medidasSeleccionadas[categoria] ?? []).isEmpty;
    }

    return ExpansionTile(
      backgroundColor: isCategoriaInvalid ? Colors.red.shade50 : null,
      collapsedBackgroundColor: isCategoriaInvalid ? Colors.red.shade100 : null,
      title: Text(categoria, style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Este tipo de peligro aplica para la tarea?',
                style: TextStyle(
                  color: (isCategoriaInvalid && aplicaCategoria[categoria] == null)
                      ? Colors.red.shade700
                      : null,
                ),
              ),
              Row(
                children: ['Sí', 'No', 'N/A'].map((opcion) {
                  return Expanded(
                    child: RadioListTile<String>(
                      title: Text(opcion),
                      value: opcion,
                      groupValue: aplicaCategoria[categoria],
                      onChanged: (String? value) {
                        setState(() {
                          aplicaCategoria[categoria] = value!;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              if (aplicaCategoria[categoria] == 'Sí') ...[
                SizedBox(height: 16),
                Text(
                  'Seleccione los peligros específicos:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: (isCategoriaInvalid && sonPeligrosInvalidos)
                        ? Colors.red.shade700
                        : null,
                  ),
                ),
                buildCheckboxList(peligrosPorCategoria[categoria]!,
                    peligroSeleccionado[categoria] ?? [], (item, selected) {}),
                SizedBox(height: 16),
                Text(
                  'Seleccione los riesgos o consecuencias:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: (isCategoriaInvalid && sonRiesgosInvalidos)
                        ? Colors.red.shade700
                        : null,
                  ),
                ),
                buildCheckboxList(riesgosPorCategoria[categoria]!,
                    riesgosSeleccionados[categoria] ?? [], (item, selected) {}),
                SizedBox(height: 16),
                Text(
                  'Seleccione las medidas de prevención o control:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: (isCategoriaInvalid && sonMedidasInvalidas)
                        ? Colors.red.shade700
                        : null,
                  ),
                ),
                buildCheckboxList(medidasPorCategoria[categoria]!,
                    medidasSeleccionadas[categoria] ?? [], (item, selected) {}),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void guardarFormulario() {
    Set<String> errores = {};
    String mensajeError =
        'Error: Revise las categorías resaltadas.';

    for (String categoria in categorias) {
      final aplica = aplicaCategoria[categoria];

      if (aplica == null) {
        errores.add(categoria);
        mensajeError =
        'Error: Debe seleccionar "Sí", "No" o "N/A" para todas las categorías.';
      }
      else if (aplica == 'Sí') {
        final bool peligrosVacios =
            (peligroSeleccionado[categoria] ?? []).isEmpty;
        final bool riesgosVacios =
            (riesgosSeleccionados[categoria] ?? []).isEmpty;
        final bool medidasVacias =
            (medidasSeleccionadas[categoria] ?? []).isEmpty;

        if (peligrosVacios || riesgosVacios || medidasVacias) {
          errores.add(categoria);
          mensajeError =
          'Error: Las categorías marcadas con "Sí" deben tener al menos una selección en cada sub-lista.';
        }
      }
    }

    setState(() {
      _categoriasInvalidas = errores;
    });

    if (errores.isEmpty) {
      if (_formKey.currentState!.validate()) {
        _data.aplicaCategoria = aplicaCategoria;
        _data.peligroSeleccionado = peligroSeleccionado;
        _data.riesgosSeleccionados = riesgosSeleccionados;
        _data.medidasSeleccionadas = medidasSeleccionadas;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Datos de peligros guardados correctamente')),
        );
        Navigator.pushNamed(context, '/herramientas', arguments: _data);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensajeError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Identificación de Peligros')),

      // --- 'body' CON PADDING INFERIOR CORREGIDO ---
      body: Form(
        key: _formKey,
        // El padding se aplica aquí para que el scroll llegue al borde
        child: Padding(
          // Padding modificado para dejar espacio al botón fijo
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
          child: ListView(
            children: [
              ...categorias
                  .map((categoria) => buildCategoria(categoria))
                  .toList(),

              // --- ¡BOTÓN ELIMINADO DE AQUÍ! ---
              // SizedBox(height: 16),
              // ElevatedButton(...)
              // --- FIN DE LA ELIMINACIÓN ---
            ],
          ),
        ),
      ),
      // --- FIN DEL CAMBIO ---

      // --- ¡BOTÓN AÑADIDO A persistentFooterButtons! ---
      persistentFooterButtons: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              child: Text('Guardar y Continuar'),
              onPressed: guardarFormulario,
            ),
          ),
        ),
      ],
      // --- FIN DE LA ADICIÓN ---
    );
  }
}