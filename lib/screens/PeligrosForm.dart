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

  // --- VARIABLE DE ESTADO MODIFICADA (Set en lugar de bool) ---
  /// Almacena los nombres de las categorías que fallan la validación.
  Set<String> _categoriasInvalidas = {};
  // --- FIN DE MODIFICACIÓN ---

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
    // --- LÓGICA DE RESALTADO VISUAL (NIVEL 2) ---
    final bool isCategoriaInvalid = _categoriasInvalidas.contains(categoria);

    // Determina si las sub-listas (si aplica 'Sí') son inválidas
    bool sonPeligrosInvalidos = false;
    bool sonRiesgosInvalidos = false;
    bool sonMedidasInvalidas = false;

    // Solo calculamos esto si la categoría es 'Sí'
    if (aplicaCategoria[categoria] == 'Sí') {
      sonPeligrosInvalidos = (peligroSeleccionado[categoria] ?? []).isEmpty;
      sonRiesgosInvalidos = (riesgosSeleccionados[categoria] ?? []).isEmpty;
      sonMedidasInvalidas = (medidasSeleccionadas[categoria] ?? []).isEmpty;
    }
    // --- FIN DE LÓGICA DE RESALTADO ---

    return ExpansionTile(
      // --- APLICACIÓN DE RESALTADO VISUAL ---
      // El fondo se resalta si la categoría *entera* es inválida (Nivel 1 o 2)
      backgroundColor: isCategoriaInvalid ? Colors.red.shade50 : null,
      collapsedBackgroundColor: isCategoriaInvalid ? Colors.red.shade100 : null,
      // --- FIN DE APLICACIÓN ---
      title: Text(categoria, style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            // --- AÑADIDO: Alinear hijos a la izquierda ---
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Este tipo de peligro aplica para la tarea?',
                // Resaltado Nivel 1 (No revisado)
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
                  // Resaltado Nivel 2 (Peligros Vacíos)
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
                  // Resaltado Nivel 2 (Riesgos Vacíos)
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
                  // Resaltado Nivel 2 (Medidas Vacías)
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

  // --- LÓGICA DE VALIDACIÓN MODIFICADA (NIVEL 2) ---
  void guardarFormulario() {
    // 1. Reiniciar el Set de errores
    Set<String> errores = {};
    String mensajeError =
        'Error: Revise las categorías resaltadas.'; // Mensaje por defecto

    // 2. Iterar por todas las categorías para validar
    for (String categoria in categorias) {
      final aplica = aplicaCategoria[categoria];

      // --- Comprobación 1 (Nivel 1): ¿Se ha revisado? ---
      if (aplica == null) {
        errores.add(categoria);
        mensajeError =
        'Error: Debe seleccionar "Sí", "No" o "N/A" para todas las categorías.';
      }
      // --- Comprobación 2 (Nivel 2): Si es "Sí", ¿las listas están llenas? ---
      else if (aplica == 'Sí') {
        final bool peligrosVacios =
            (peligroSeleccionado[categoria] ?? []).isEmpty;
        final bool riesgosVacios =
            (riesgosSeleccionados[categoria] ?? []).isEmpty;
        final bool medidasVacias =
            (medidasSeleccionadas[categoria] ?? []).isEmpty;

        if (peligrosVacios || riesgosVacios || medidasVacias) {
          errores.add(categoria); // Añadir a inválidos si alguna lista está vacía
          mensajeError =
          'Error: Las categorías marcadas con "Sí" deben tener al menos una selección en cada sub-lista.';
        }
      }
    }

    // 3. Actualizar el estado y navegar si no hay errores
    setState(() {
      _categoriasInvalidas = errores;
    });

    if (errores.isEmpty) {
      // Si no hay errores, guardar y navegar
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
      // Si hay errores, mostrar el SnackBar con el mensaje de error específico
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensajeError)),
      );
    }
  }
  // --- FIN DE LÓGICA DE VALIDACIÓN ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Identificación de Peligros')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ...categorias
                  .map((categoria) => buildCategoria(categoria))
                  .toList(),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text('Guardar y Continuar'),
                onPressed: guardarFormulario,
              ),
            ],
          ),
        ),
      ),
    );
  }
}