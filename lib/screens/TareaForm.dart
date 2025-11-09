import 'package:flutter/material.dart';
// Corregida la ruta de importación para Android Studio
import 'package:identificador_riesgos/models/permiso_data.dart';

class TareaForm extends StatefulWidget {
  @override
  _TareaFormState createState() => _TareaFormState();
}

class _TareaFormState extends State<TareaForm> {
  final _formKey = GlobalKey<FormState>();
  late PermisoData _data;
  bool _initialized = false;

  String descripcion = '';
  String codigoAST = '';
  String ordenTrabajo = '';
  String ubicacion = '';

  late DateTime fechaInicio;
  late DateTime fechaFin;
  late TimeOfDay horaInicio;
  late TimeOfDay horaFin;

  bool existeAST = false; // Control para validar si hay AST

  bool _requierePermisosEspeciales = false;

  Map<String, bool> permisosEspeciales = {
    'Trabajo en alturas': false,
    'Espacios confinados': false,
    'Corte y soldadura': false,
    'Trabajo eléctrico': false,
    'Sustancias químicas': false,
    'Maquinaria': false,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      _data = args is PermisoData ? args : PermisoData();

      final now = DateTime.now();

      setState(() {
        descripcion = _data.descripcion;
        codigoAST = _data.codigoAST;
        ordenTrabajo = _data.ordenTrabajo;
        ubicacion = _data.ubicacion;

        fechaInicio = DateTime(now.year, now.month, now.day);
        fechaFin = DateTime(now.year, now.month, now.day);
        horaInicio = _data.horaInicio ?? TimeOfDay.now();
        horaFin = _data.horaFin ?? TimeOfDay.now();

        permisosEspeciales = Map.from(_data.permisosEspeciales);
        existeAST = _data.existeAST;

        _requierePermisosEspeciales = permisosEspeciales.values.any((v) => v);
      });
      _initialized = true;
    }
  }

  Future<void> _selectHoraInicio() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: horaInicio,
    );
    if (picked != null) setState(() => horaInicio = picked);
  }

  Future<void> _selectHoraFin() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: horaFin,
    );
    if (picked != null) setState(() => horaFin = picked);
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} (Fecha Actual)';
  }

  String formatTime(TimeOfDay time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _setPermisosEspeciales(bool value) {
    setState(() {
      _requierePermisosEspeciales = value;
      if (!value) {
        permisosEspeciales.updateAll((key, _) => false);
      }
    });
  }


  void _continuar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final dtInicio = DateTime(fechaInicio.year, fechaInicio.month,
        fechaInicio.day, horaInicio.hour, horaInicio.minute);
    final dtFin = DateTime(fechaFin.year, fechaFin.month, fechaFin.day,
        horaFin.hour, horaFin.minute);

    if (dtFin.isBefore(dtInicio) || dtFin.isAtSameMomentAs(dtInicio)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error: La hora de fin debe ser posterior a la hora de inicio')),
      );
      return;
    }

    final duration = dtFin.difference(dtInicio);
    if (duration.inMinutes > (12 * 60)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error: La vigencia del permiso no puede superar las 12 horas')),
      );
      return;
    }

    if (existeAST && codigoAST.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debe ingresar el código del AST')),
      );
      return;
    }

    _data.descripcion = descripcion;
    _data.codigoAST = codigoAST;
    _data.ordenTrabajo = ordenTrabajo;
    _data.ubicacion = ubicacion;
    _data.fechaInicio = fechaInicio;
    _data.horaInicio = horaInicio;
    _data.fechaFin = fechaFin;
    _data.horaFin = horaFin;
    _data.permisosEspeciales = permisosEspeciales;
    _data.existeAST = existeAST;

    Navigator.pushNamed(context, '/peligros', arguments: _data);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building TareaForm at ${DateTime.now()}');
    return Scaffold(
      appBar: AppBar(title: Text('Datos de la Tarea')),

      // --- 'body' CON PADDING INFERIOR CORREGIDO ---
      body: SingleChildScrollView(
        // Padding modificado para dejar espacio al botón fijo
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: descripcion,
                decoration:
                InputDecoration(labelText: 'Descripción de la tarea'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                onChanged: (value) => descripcion = value,
              ),
              TextFormField(
                initialValue: ordenTrabajo,
                decoration:
                InputDecoration(labelText: 'Número de orden de trabajo'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                onChanged: (value) => ordenTrabajo = value,
              ),
              TextFormField(
                initialValue: ubicacion,
                decoration: InputDecoration(labelText: 'Ubicación'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                onChanged: (value) => ubicacion = value,
              ),
              SizedBox(height: 16),
              Text('¿Existe un AST (Análisis de Seguridad de Tarea)?',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: Text('Sí'),
                      value: true,
                      groupValue: existeAST,
                      onChanged: (value) {
                        setState(() {
                          existeAST = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: Text('No'),
                      value: false,
                      groupValue: existeAST,
                      onChanged: (value) {
                        setState(() {
                          existeAST = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              if (existeAST)
                TextFormField(
                  initialValue: codigoAST,
                  decoration: InputDecoration(labelText: 'Código del AST'),
                  validator: (value) =>
                  value!.isEmpty ? 'Campo requerido' : null,
                  onChanged: (value) => codigoAST = value,
                ),

              SizedBox(height: 16),
              Text('Fecha y hora de inicio',
                  style: TextStyle(fontWeight: FontWeight.bold)),

              Text('Fecha: ${formatDate(fechaInicio)} (No editable)'),
              Row(
                children: [
                  Text('Hora: ${formatTime(horaInicio)}'),
                  SizedBox(width: 10),
                  ElevatedButton(
                      onPressed: _selectHoraInicio,
                      child: Text('Seleccionar hora')),
                ],
              ),

              SizedBox(height: 16),
              Text('Fecha y hora de fin',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Fecha: ${formatDate(fechaFin)} (No editable)'),
              Row(
                children: [
                  Text('Hora: ${formatTime(horaFin)}'),
                  SizedBox(width: 10),
                  ElevatedButton(
                      onPressed: _selectHoraFin,
                      child: Text('Seleccionar hora')),
                ],
              ),

              SizedBox(height: 16),

              SwitchListTile(
                title: Text('¿Se requieren permisos especiales?', style: TextStyle(fontWeight: FontWeight.bold)),
                value: _requierePermisosEspeciales,
                onChanged: _setPermisosEspeciales,
              ),

              Visibility(
                visible: _requierePermisosEspeciales,
                child: Column(
                  children: permisosEspeciales.keys.map((permiso) {
                    return CheckboxListTile(
                      title: Text(permiso),
                      value: permisosEspeciales[permiso],
                      onChanged: (value) {
                        setState(() {
                          permisosEspeciales[permiso] = value!;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),

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
            width: double.infinity, // Hace que el botón ocupe todo el ancho
            child: ElevatedButton(
              child: Text('Continuar con identificación de peligros'),
              onPressed: _continuar,
            ),
          ),
        ),
      ],
      // --- FIN DE LA ADICIÓN ---
    );
  }
}