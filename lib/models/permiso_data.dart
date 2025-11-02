import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
// Importación de paquete corregida para Android Studio
import 'package:identificador_riesgos/constants.dart';

class PermisoData {
  String descripcion = '';
  String codigoAST = '';
  String ordenTrabajo = '';
  String ubicacion = '';
  DateTime? fechaInicio;
  TimeOfDay? horaInicio;
  DateTime? fechaFin;
  TimeOfDay? horaFin;
  Map<String, bool> permisosEspeciales = {
    'Trabajo en alturas': false,
    'Espacios confinados': false,
    'Corte y soldadura': false,
    'Trabajo eléctrico': false,
    'Sustancias químicas': false,
    'Maquinaria': false,
  };
  bool existeAST = false;

  // --- ¡CAMBIO 1: TIPO MODIFICADO! ---
  // Ahora permite valores nulos (null)
  Map<String, String?> aplicaCategoria = {};
  // --- FIN DEL CAMBIO ---

  Map<String, List<String>> peligroSeleccionado = {};
  Map<String, List<String>> riesgosSeleccionados = {};
  Map<String, List<String>> medidasSeleccionadas = {};
  Map<String, String> respuestas4P = {};
  Map<String, String> respuestasEntorno = {};
  List<Map<String, dynamic>> pasos = [];
  String? nombreDiligenciador;
  Uint8List? firmaDiligenciador;
  String? nombreInterventor;
  Uint8List? firmaInterventor;

  PermisoData() {
    for (var categoria in peligrosPorCategoria.keys) {

      // --- ¡CAMBIO 2: VALOR POR DEFECTO MODIFICADO! ---
      // 'null' ahora significa "No Revisado"
      aplicaCategoria[categoria] = null;
      // --- FIN DEL CAMBIO ---

      peligroSeleccionado[categoria] = [];
      riesgosSeleccionados[categoria] = [];
      medidasSeleccionadas[categoria] = [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'descripcion': descripcion,
      'codigoAST': codigoAST,
      'ordenTrabajo': ordenTrabajo,
      'ubicacion': ubicacion,
      'fechaInicio': fechaInicio?.toIso8601String(),
      'horaInicio': horaInicio != null
          ? {'hour': horaInicio!.hour, 'minute': horaInicio!.minute}
          : null,
      'fechaFin': fechaFin?.toIso8601String(),
      'horaFin': horaFin != null
          ? {'hour': horaFin!.hour, 'minute': horaFin!.minute}
          : null,
      'permisosEspeciales': permisosEspeciales,
      'existeAST': existeAST,
      'aplicaCategoria': aplicaCategoria, // Esto es compatible con JSON
      'peligroSeleccionado': peligroSeleccionado,
      'riesgosSeleccionados': riesgosSeleccionados,
      'medidasSeleccionadas': medidasSeleccionadas,
      'respuestas4P': respuestas4P,
      'respuestasEntorno': respuestasEntorno,
      'pasos': pasos,
      'nombreDiligenciador': nombreDiligenciador,
      'firmaDiligenciador':
      firmaDiligenciador != null ? base64Encode(firmaDiligenciador!) : null,
      'nombreInterventor': nombreInterventor,
      'firmaInterventor':
      firmaInterventor != null ? base64Encode(firmaInterventor!) : null,
    };
  }

  factory PermisoData.fromJson(Map<String, dynamic> json) {
    final permiso = PermisoData();
    permiso.descripcion = json['descripcion'] ?? '';
    permiso.codigoAST = json['codigoAST'] ?? '';
    permiso.ordenTrabajo = json['ordenTrabajo'] ?? '';
    permiso.ubicacion = json['ubicacion'] ?? '';
    permiso.fechaInicio = json['fechaInicio'] != null
        ? DateTime.parse(json['fechaInicio'])
        : null;
    permiso.horaInicio = json['horaInicio'] != null
        ? TimeOfDay(
        hour: json['horaInicio']['hour'],
        minute: json['horaInicio']['minute'])
        : null;
    permiso.fechaFin =
    json['fechaFin'] != null ? DateTime.parse(json['fechaFin']) : null;
    permiso.horaFin = json['horaFin'] != null
        ? TimeOfDay(
        hour: json['horaFin']['hour'], minute: json['horaFin']['minute'])
        : null;
    permiso.permisosEspeciales = Map<String, bool>.from(
        json['permisosEspeciales'] ?? permiso.permisosEspeciales);
    permiso.existeAST = json['existeAST'] ?? false;

    // --- ¡CAMBIO 3: TIPO MODIFICADO! ---
    // Asegura que el Map de 'fromJson' acepte nulos (String?)
    // Y lo inicializa desde los datos guardados, si existen.
    final categoriasGuardadas = Map<String, String?>.from(json['aplicaCategoria'] ?? {});
    // Asegura que todas las claves existan, incluso si se añaden nuevas categorías en el futuro
    for (var categoria in peligrosPorCategoria.keys) {
      permiso.aplicaCategoria[categoria] = categoriasGuardadas[categoria]; // Será 'null' si no existe
    }
    // --- FIN DEL CAMBIO ---

    permiso.peligroSeleccionado =
        (json['peligroSeleccionado'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(key, List<String>.from(value ?? [])),
        ) ??
            {};
    permiso.riesgosSeleccionados =
        (json['riesgosSeleccionados'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(key, List<String>.from(value ?? [])),
        ) ??
            {};
    permiso.medidasSeleccionadas =
        (json['medidasSeleccionadas'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(key, List<String>.from(value ?? [])),
        ) ??
            {};
    permiso.respuestas4P = Map<String, String>.from(json['respuestas4P'] ?? {});
    permiso.respuestasEntorno =
    Map<String, String>.from(json['respuestasEntorno'] ?? {});
    permiso.pasos = List<Map<String, dynamic>>.from(json['pasos'] ?? []);
    permiso.nombreDiligenciador = json['nombreDiligenciador'];
    permiso.firmaDiligenciador = json['firmaDiligenciador'] != null
        ? base64Decode(json['firmaDiligenciador'])
        : null;
    permiso.nombreInterventor = json['nombreInterventor'];
    permiso.firmaInterventor = json['firmaInterventor'] != null
        ? base64Decode(json['firmaInterventor'])
        : null;
    return permiso;
  }
}