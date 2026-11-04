/// Reglas y validaciones de clientes (lógica pura, sin base de datos ni pantallas).
library;

import '../core/dinero.dart';

/// Quita acentos y mayúsculas para comparar textos: "Ángel Núñez" -> "angel nunez".
String normalizar(String texto) {
  const conAcento = 'áàäâéèëêíìïîóòöôúùüûñ';
  const sinAcento = 'aaaaeeeeiiiioooouuuun';
  final buffer = StringBuffer();
  for (final c in texto.toLowerCase().split('')) {
    final i = conAcento.indexOf(c);
    buffer.write(i >= 0 ? sinAcento[i] : c);
  }
  return buffer.toString().trim();
}

/// True si [busqueda] aparece en alguno de los [campos] (ignora acentos y mayúsculas).
/// Una búsqueda vacía coincide con todo.
bool coincideBusqueda(String busqueda, List<String?> campos) {
  final b = normalizar(busqueda);
  if (b.isEmpty) return true;
  return campos.any((c) => c != null && normalizar(c).contains(b));
}

/// Día de corte sugerido para un cliente nuevo: el día del alta, máximo 28.
int diaCorteSugerido(DateTime fechaAlta) => fechaAlta.day > 28 ? 28 : fechaAlta.day;

// ---------------------------------------------------------------------------
// Validaciones de formulario. Devuelven el mensaje de error o null si es válido.
// ---------------------------------------------------------------------------

String? validarNombre(String? valor) {
  final v = valor?.trim() ?? '';
  if (v.isEmpty) return 'Escribe el nombre';
  if (v.length < 3) return 'El nombre es muy corto';
  return null;
}

/// Teléfono opcional; si se escribe debe tener 10 dígitos (México).
String? validarTelefono(String? valor) {
  final v = valor?.trim() ?? '';
  if (v.isEmpty) return null;
  final digitos = v.replaceAll(RegExp(r'[\s\-()]'), '');
  if (!RegExp(r'^\d{10}$').hasMatch(digitos)) {
    return 'Debe tener 10 dígitos';
  }
  return null;
}

/// Deja solo los dígitos de un teléfono: "771 123-4567" -> "7711234567".
String? limpiarTelefono(String? valor) {
  final v = valor?.replaceAll(RegExp(r'\D'), '') ?? '';
  return v.isEmpty ? null : v;
}

/// Monto obligatorio y mayor a cero.
String? validarMontoObligatorio(String? valor) {
  final v = valor?.trim() ?? '';
  if (v.isEmpty) return 'Escribe el monto';
  try {
    if (textoACentavos(v) <= 0) return 'Debe ser mayor a \$0';
  } on FormatException {
    return 'Monto no válido';
  }
  return null;
}

/// Monto opcional (vacío = 0).
String? validarMontoOpcional(String? valor) {
  final v = valor?.trim() ?? '';
  if (v.isEmpty) return null;
  try {
    textoACentavos(v);
  } on FormatException {
    return 'Monto no válido';
  }
  return null;
}

/// Convierte texto opcional a null si está vacío.
String? textoONull(String? valor) {
  final v = valor?.trim() ?? '';
  return v.isEmpty ? null : v;
}

/// Un cliente con equipo prestado debe tener registrado al menos un equipo de
/// NetMAX instalado (sin retirar), para poder recuperarlo después.
bool faltaRegistrarEquipoPrestado({
  required bool esEquipoPrestado,
  required int equiposNetmaxInstalados,
}) =>
    esEquipoPrestado && equiposNetmaxInstalados == 0;

/// Agrupa las descripciones de contratación personalizadas (sin distinguir
/// mayúsculas, acentos ni espacios), de la más usada a la menos usada.
/// Se muestra la primera forma en que se escribió cada una.
List<({String detalle, int clientes})> agruparDetalles(Iterable<String?> detalles) {
  final conteo = <String, ({String detalle, int clientes})>{};
  for (final d in detalles) {
    final texto = d?.trim() ?? '';
    if (texto.isEmpty) continue;
    final clave = normalizar(texto);
    final previo = conteo[clave];
    conteo[clave] = (detalle: previo?.detalle ?? texto, clientes: (previo?.clientes ?? 0) + 1);
  }
  return conteo.values.toList()
    ..sort((a, b) => b.clientes != a.clientes
        ? b.clientes.compareTo(a.clientes)
        : normalizar(a.detalle).compareTo(normalizar(b.detalle)));
}

/// La descripción es obligatoria cuando la contratación es "otro".
String? validarDetalleContratacion(String? valor) {
  final v = valor?.trim() ?? '';
  if (v.isEmpty) return 'Describe el tipo de contratación';
  if (v.length > 80) return 'Máximo 80 caracteres';
  return null;
}
