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

  // --- NUEVA VARIABLE DE ESTADO PARA VALIDACIÓN ---
  /// Almacena las preguntas específicas que fallan la validación.
  Set<String> _preguntasInvalidas = {};
  // --- FIN DE NUEVA VARIABLE ---

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
        // 1. Cargar los datos guardados
        respuestas4P = Map.from(_data.respuestas4P);
        respuestasEntorno = Map.from(_data.respuestasEntorno);

        // 2. Establecer valores por defecto ('' = No respondido)
        // Usar putIfAbsent para no sobrescribir los datos ya cargados.
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

  // --- LÓGICA DE 'initState' ELIMINADA ---
  // Se movió a didChangeDependencies para asegurar el orden correcto de carga.

  Widget buildRadio(String pregunta, Map<String, String> respuestas) {
    // --- LÓGICA DE RESALTADO VISUAL (NIVEL 2) ---
    final bool isInvalid = _preguntasInvalidas.contains(pregunta);
    // --- FIN DE LÓGICA ---

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pregunta,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            // Resalta el texto de la pregunta si es inválida
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

  // --- LÓGICA DE VALIDACIÓN MODIFICADA ---
  void _guardarYContinuar() {
    // 1. Reiniciar el Set de errores
    Set<String> errores = {};

    // 2. Comprobar ambas listas
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

    // 3. Actualizar el estado
    setState(() {
      _preguntasInvalidas = errores;
    });

    // 4. Navegar o mostrar error
    if (errores.isEmpty) {
      // Si no hay errores, guardar y navegar
      _data.respuestas4P = respuestas4P;
      _data.respuestasEntorno = respuestasEntorno;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Formulario guardado correctamente')));

      // Lógica de navegación condicional (existente)
      if (_data.existeAST) {
        Navigator.pushNamed(context, '/firmas', arguments: _data);
      } else {
        Navigator.pushNamed(context, '/pasoapaso', arguments: _data);
      }
    } else {
      // Si hay errores, mostrar SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error: Por favor, responda "Sí" o "No" a todas las preguntas resaltadas.')),
      );
    }
  }
  // --- FIN DEL CAMBIO ---

  @override
  Widget build(BuildContext context) {

    // --- LÓGICA DE RESALTADO VISUAL (NIVEL 1) ---
    // Determina si las secciones (ExpansionTile) contienen errores
    final bool seccion4PInvalid =
    aplico4P.any((p) => _preguntasInvalidas.contains(p));
    final bool seccionEntornoInvalid =
    analizoEntorno.any((p) => _preguntasInvalidas.contains(p));
    // --- FIN DE LÓGICA ---

    return Scaffold(
      appBar: AppBar(title: Text('Herramientas de Seguridad')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ExpansionTile(
              title: Text('Aplico las 4P'),
              // --- APLICACIÓN DE RESALTADO VISUAL (NIVEL 1) ---
              backgroundColor: seccion4PInvalid ? Colors.red.shade50 : null,
              collapsedBackgroundColor:
              seccion4PInvalid ? Colors.red.shade100 : null,
              // --- FIN DE APLICACIÓN ---
              children: aplico4P
                  .map((pregunta) => buildRadio(pregunta, respuestas4P))
                  .toList(),
            ),
            ExpansionTile(
              title: Text('Analizo mi entorno'),
              // --- APLICACIÓN DE RESALTADO VISUAL (NIVEL 1) ---
              backgroundColor: seccionEntornoInvalid ? Colors.red.shade50 : null,
              collapsedBackgroundColor:
              seccionEntornoInvalid ? Colors.red.shade100 : null,
              // --- FIN DE APLICACIÓN ---
              children: analizoEntorno
                  .map((pregunta) => buildRadio(pregunta, respuestasEntorno))
                  .toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarYContinuar,
              child: Text('Guardar / Continuar'),
            )
          ],
        ),
      ),
    );
  }
}