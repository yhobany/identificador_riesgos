library constants;

const Map<String, List<String>> peligrosPorCategoria = {
  'Biológico': ['Insectos', 'Animales', 'Fluidos o excrementos', 'Otros'],
  'Físico': ['Ruido', 'Radiación', 'Temperatura extrema', 'Otros'],
  'Químico': ['Gases', 'Vapores', 'Líquidos corrosivos', 'Otros'],
  'Biomecánico': [
    'Posturas forzadas',
    'Carga manual',
    'Movimientos repetitivos',
    'Otros'
  ],
  'Condiciones de seguridad': [
    'Orden y limpieza',
    'Señalización',
    'Iluminación',
    'Otros'
  ],
  'Mecánico': [
    'Equipos en movimiento',
    'Herramientas manuales',
    'Partes móviles',
    'Otros'
  ],
  'Eléctrico': [
    'Líneas energizadas',
    'Equipos eléctricos',
    'Redes de distribución',
    'Otros'
  ],
  'Espacios confinados': [
    'Falta de ventilación',
    'Atmósfera peligrosa',
    'Acceso limitado',
    'Otros'
  ],
  'Trabajo en alturas': [
    'Caídas',
    'Superficies inestables',
    'Falta de protección',
    'Otros'
  ],
  'Fenómenos naturales': ['Sismos', 'Tormentas', 'Inundaciones', 'Otros'],
  'Medio ambiente': [
    'Contaminación',
    'Derrames',
    'Residuos peligrosos',
    'Otros'
  ],
};

const Map<String, List<String>> riesgosPorCategoria = {
  'Biológico': [
    'Mordedura de animales',
    'Picadura de insectos',
    'Reacciones alérgicas',
    'Enfermedades',
    'Intoxicación'
  ],
  'Físico': ['Sordera', 'Quemaduras', 'Golpe de calor', 'Hipotermia'],
  'Químico': [
    'Irritación',
    'Intoxicación',
    'Quemaduras químicas',
    'Afecciones respiratorias'
  ],
  'Biomecánico': ['Dolor muscular', 'Lesión articular', 'Fatiga física'],
  'Condiciones de seguridad': ['Caídas', 'Choques', 'Atropellos'],
  'Mecánico': ['Golpes', 'Cortes', 'Amputaciones'],
  'Eléctrico': ['Electrocución', 'Quemaduras', 'Falla de equipos'],
  'Espacios confinados': ['Asfixia', 'Intoxicación', 'Desmayo'],
  'Trabajo en alturas': ['Caída libre', 'Golpe por caída de objetos'],
  'Fenómenos naturales': ['Derrumbes', 'Inundaciones', 'Impacto por tormenta'],
  'Medio ambiente': [
    'Contaminación del agua',
    'Contaminación del aire',
    'Afectación a fauna y flora'
  ],
};

const Map<String, List<String>> medidasPorCategoria = {
  'Biológico': [
    'Uso de EPP adecuado',
    'Vacunación',
    'Control de plagas',
    'Higiene personal',
    'Señalización del área'
  ],
  'Físico': [
    'Protección auditiva',
    'Ropa térmica',
    'Hidratación',
    'Ventilación'
  ],
  'Químico': [
    'Hoja de seguridad',
    'Kit de derrames',
    'Ducha de emergencia',
    'EPP químico'
  ],
  'Biomecánico': [
    'Pausas activas',
    'Capacitación en ergonomía',
    'Uso de ayudas mecánicas'
  ],
  'Condiciones de seguridad': [
    'Capacitación en seguridad',
    'Inspección regular',
    'Señalización adecuada'
  ],
  'Mecánico': [
    'Guardas de protección',
    'Mantenimiento de equipos',
    'Capacitación en uso'
  ],
  'Eléctrico': [
    'Bloqueo y etiquetado',
    'EPP aislante',
    'Pruebas de aislamiento'
  ],
  'Espacios confinados': [
    'Monitoreo de atmósfera',
    'Permiso de entrada',
    'Equipo de rescate'
  ],
  'Trabajo en alturas': [
    'Arnés de seguridad',
    'Barandillas',
    'Capacitación en alturas'
  ],
  'Fenómenos naturales': [
    'Plan de emergencia',
    'Evacuación',
    'Monitoreo climático'
  ],
  'Medio ambiente': [
    'Separación de residuos',
    'Uso racional de recursos',
    'Control de derrames'
  ],
};
