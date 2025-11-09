import 'package:flutter/material.dart';
// Corrección de ruta para Android Studio
import 'package:identificador_riesgos/models/permiso_data.dart';

class HerramientasSeguridad extends StatefulWidget {
  @override
  _HerramientasSeguridadState createState() => _HerramientasSeguridadState();
}

class _HerramientasSeguridadState extends State<HerramientasSeguridad> {
  late PermisoData _data;
  bool _initialized = false;

  Map<String, String> respuestas4P = {};
  Map<String, String> respuestasEntorno = {};

  Set<String> _preguntasInvalidas = {};

  List<String> aplico4P = [
    '¿Comienzo?',
    '¿Puedo fijar toda mi atención en la tarea?',
    '¿Cuento con los elementos de seguridad?',
    '¿Realmente puedo hacer la tarea?',
    '¿Tengo la habilidad requerida?',
    '¿Cómo está todo y todos a mi alrededor?',
    '¿Cuento con todo lo necesario?',
    '¿Tengo claro lo que debo hacer?',
    '¿Hay algo diferente este día?',
    '¿Debo tomar un camino alternativo?',
    '¿Qué alternativas tengo?',
    '¿Es un camino seguro?',
    '¿Debo consultar con alguien?',
    '¿Aplico el procedimiento que definí?',
    '¿Pongo mi atención para monitorear la seguridad?',
    '¿Comunico y solicito apoyo en caso de ser requerido?'
  ];
  List<String> analizoEntorno = [
    '¿He analizado el entorno arriba?',
    '¿He analizado el entorno abajo?',
    '¿He analizado el entorno adelante?',
    '¿He analizado el entorno atrás?',
    '¿He analizado el entorno a un lado?',
    '¿He analizado el entorno al otro lado?',
    '¿He analizado el entorno adentro (“Tu actitud”)?'
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)!.settings.arguments as PermisoData;
      _data = args;
      setState(() {
        respuestas4P = Map.from(_data.respuestas4P);
        respuestasEntorno = Map.from(_data.respuestasEntorno);

        for (var pregunta in aplico4P) {
          respuestas4P.putIfAbsent(pregunta, () => '');
        }
        for (var pregunta in analizoEntorno) {
          respuestasEntorno.putIfAbsent(pregunta, () => '');
        }
      });
      _initialized = true;
    }
  }

  Widget buildRadio(String pregunta, Map<String, String> respuestas) {
    final bool isInvalid = _preguntasInvalidas.contains(pregunta);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pregunta,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isInvalid ? Colors.red.shade700 : null,
          ),
        ),
        RadioListTile<String>(
          title: Text('Sí'),
          value: 'Sí',
          groupValue: respuestas[pregunta],
          onChanged: (value) {
            setState(() {
              respuestas[pregunta] = value!;
            });
          },
        ),
        RadioListTile<String>(
          title: Text('No'),
          value: 'No',
          groupValue: respuestas[pregunta],
          onChanged: (value) {
            setState(() {
              respuestas[pregunta] = value!;
            });
          },
        ),
        Divider()
      ],
    );
  }

  void _guardarYContinuar() {
    Set<String> errores = {};

    for (var pregunta in aplico4P) {
      if (respuestas4P[pregunta] == '') {
        errores.add(pregunta);
      }
    }
    for (var pregunta in analizoEntorno) {
      if (respuestasEntorno[pregunta] == '') {
        errores.add(pregunta);
      }
    }

    setState(() {
      _preguntasInvalidas = errores;
    });

    if (errores.isEmpty) {
      _data.respuestas4P = respuestas4P;
      _data.respuestasEntorno = respuestasEntorno;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Formulario guardado correctamente')));

      // --- ¡NAVEGACIÓN CORREGIDA AQUÍ! ---
      if (_data.existeAST) {
        // Si SÍ hay AST, va a la VISTA PREVIA
        Navigator.pushNamed(context, '/ver_reporte', arguments: _data);
      } else {
        // Si NO hay AST, va a la pantalla de Paso a Paso (esto está bien)
        Navigator.pushNamed(context, '/pasoapaso', arguments: _data);
      }
      // --- FIN DE CORRECCIÓN ---
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error: Por favor, responda "Sí" o "No" a todas las preguntas resaltadas.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool seccion4PInvalid =
    aplico4P.any((p) => _preguntasInvalidas.contains(p));
    final bool seccionEntornoInvalid =
    analizoEntorno.any((p) => _preguntasInvalidas.contains(p));

    return Scaffold(
      appBar: AppBar(title: Text('Herramientas de Seguridad')),

      // --- 'body' CON PADDING INFERIOR CORREGIDO ---
      body: SingleChildScrollView(
        // Padding modificado para dejar espacio al botón fijo
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
        child: Column(
          children: [
            ExpansionTile(
              title: Text('Aplico las 4P'),
              backgroundColor: seccion4PInvalid ? Colors.red.shade50 : null,
              collapsedBackgroundColor:
              seccion4PInvalid ? Colors.red.shade100 : null,
              children: aplico4P
                  .map((pregunta) => buildRadio(pregunta, respuestas4P))
                  .toList(),
            ),
            ExpansionTile(
              title: Text('Analizo mi entorno'),
              backgroundColor: seccionEntornoInvalid ? Colors.red.shade50 : null,
              collapsedBackgroundColor:
              seccionEntornoInvalid ? Colors.red.shade100 : null,
              children: analizoEntorno
                  .map((pregunta) => buildRadio(pregunta, respuestasEntorno))
                  .toList(),
            ),

            // --- ¡BOTÓN ELIMINADO DE AQUÍ! ---
            // SizedBox(height: 20),
            // ElevatedButton(...)
            // --- FIN DE LA ELIMINACIÓN ---
          ],
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
              onPressed: _guardarYContinuar,
              child: Text('Guardar / Continuar'),
            ),
          ),
        ),
      ],
      // --- FIN DE LA ADICIÓN ---
    );
  }
}