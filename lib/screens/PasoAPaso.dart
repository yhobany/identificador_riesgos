import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/permiso_data.dart';

class PasoAPasoScreen extends StatefulWidget {
  @override
  _PasoAPasoScreenState createState() => _PasoAPasoScreenState();
}

class _PasoAPasoScreenState extends State<PasoAPasoScreen> {
  final _formKey = GlobalKey<FormState>();
  late PermisoData _data;
  bool _initialized = false;

  final TextEditingController _pasoTareaController = TextEditingController();
  List<String> _peligrosSeleccionados = [];
  List<String> _medidasSeleccionadas = [];
  List<Map<String, dynamic>> _pasos = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)!.settings.arguments as PermisoData;
      _data = args;
      setState(() {
        _pasos = List.from(_data.pasos);
      });
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _pasoTareaController.dispose();
    super.dispose();
  }

  void _guardarPaso() {
    if (_formKey.currentState!.validate() &&
        !_data.existeAST &&
        _pasoTareaController.text.isNotEmpty &&
        _peligrosSeleccionados.isNotEmpty &&
        _medidasSeleccionadas.isNotEmpty) {
      setState(() {
        _pasos.add({
          'numero': _pasos.length + 1,
          'pasoTarea': _pasoTareaController.text,
          'peligros': List.from(_peligrosSeleccionados),
          'medidas': List.from(_medidasSeleccionadas),
        });
        _data.pasos = _pasos;
        _peligrosSeleccionados = [];
        _medidasSeleccionadas = [];
        _pasoTareaController.clear(); // Limpia el campo inmediatamente
      });
      _formKey.currentState!.reset(); // Reinicia el formulario
      _mostrarDialogoAgregarPaso();
    } else if (_data.existeAST) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pueden agregar pasos con AST existente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Completa todos los campos requeridos')),
      );
    }
  }

  void _mostrarDialogoAgregarPaso() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Agregar otro paso?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sí'),
          ),
        ],
      ),
    ).then((addAnother) {
      if (addAnother == null || !addAnother) {
        _finalizarPasos();
      } else {
        // Reinicio completo del formulario y limpieza explícita
        setState(() {
          _peligrosSeleccionados = [];
          _medidasSeleccionadas = [];
          _pasoTareaController.clear(); // Limpia el campo
        });
        _formKey.currentState!
            .reset(); // Reinicia todos los campos del formulario
        // Forzar renderizado inmediato
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _pasoTareaController.text = ''; // Asegura que el texto esté vacío
          setState(() {});
        });
      }
    });
  }

  void _finalizarPasos() {
    _data.pasos = _pasos;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pasos guardados correctamente')),
    );
    Navigator.pushNamed(context, '/firmas',
        arguments: _data); // Navegación a '/firmas'
  }

  Widget buildCheckboxList(
      List<String> items, List<String> selectedItems, String title) {
    return ExpansionTile(
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      children: items.map((item) {
        return CheckboxListTile(
          title: Text(item),
          value: selectedItems.contains(item),
          onChanged: _data.existeAST
              ? null
              : (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedItems.add(item);
                    } else {
                      selectedItems.remove(item);
                    }
                  });
                },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDisabled = _data.existeAST;

    return Scaffold(
      appBar: AppBar(title: Text('Paso a Paso')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDisabled)
                  Text(
                    'Este formulario está deshabilitado porque existe un AST.',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                if (!isDisabled)
                  Column(
                    children: [
                      Text(
                        'Declaración del Paso a Paso de la Tarea',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        enabled: !isDisabled,
                        controller: _pasoTareaController,
                        decoration:
                            InputDecoration(labelText: 'Paso de la Tarea'),
                        validator: (value) =>
                            !isDisabled && (value == null || value.isEmpty)
                                ? 'Campo requerido'
                                : null,
                      ),
                      SizedBox(height: 16),
                      buildCheckboxList(
                          peligrosPorCategoria.keys.toList(),
                          _peligrosSeleccionados,
                          'Seleccione los peligros asociados:'),
                      SizedBox(height: 16),
                      if (_peligrosSeleccionados.isNotEmpty)
                        buildCheckboxList(
                            _peligrosSeleccionados
                                .expand((categoria) =>
                                    medidasPorCategoria[categoria]!)
                                .toSet()
                                .toList(),
                            _medidasSeleccionadas,
                            'Seleccione las medidas de prevención o control:'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: isDisabled ? null : _guardarPaso,
                        child: Text('Guardar Paso'),
                      ),
                    ],
                  ),
                SizedBox(height: 16),
                if (_pasos.isNotEmpty && !isDisabled)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pasos Guardados',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 200,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 16.0,
                              columns: [
                                DataColumn(label: Text('No.')),
                                DataColumn(label: Text('Paso de la Tarea')),
                                DataColumn(label: Text('Peligros')),
                                DataColumn(label: Text('Medidas')),
                              ],
                              rows: _pasos.map((paso) {
                                return DataRow(cells: [
                                  DataCell(Text(paso['numero'].toString())),
                                  DataCell(Text(paso['pasoTarea'])),
                                  DataCell(Text(paso['peligros'].join(', '))),
                                  DataCell(Text(paso['medidas'].join(', '))),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
