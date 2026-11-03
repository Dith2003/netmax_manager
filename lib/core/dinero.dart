/// Utilidades de dinero.
///
/// Todos los montos se manejan en CENTAVOS (int). Nunca usar double para dinero.
/// Ejemplo: $250.00 = 25000.
library;

/// Convierte centavos a texto: 125050 -> "$1,250.50".
String formatoDinero(int centavos) {
  final negativo = centavos < 0;
  final abs = centavos.abs();
  final pesos = (abs ~/ 100).toString();
  final cent = (abs % 100).toString().padLeft(2, '0');

  final buffer = StringBuffer();
  for (var i = 0; i < pesos.length; i++) {
    if (i > 0 && (pesos.length - i) % 3 == 0) buffer.write(',');
    buffer.write(pesos[i]);
  }
  return '${negativo ? '-' : ''}\$$buffer.$cent';
}

/// Convierte texto capturado por el usuario a centavos.
/// Acepta: "250", "250.5", "250.50", "$1,250.00".
/// Lanza [FormatException] si el texto no es un monto válido.
int textoACentavos(String texto) {
  final limpio = texto.replaceAll(RegExp(r'[\s$,]'), '');
  final match = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$').firstMatch(limpio);
  if (match == null) {
    throw FormatException('Monto no válido', texto);
  }
  final pesos = int.parse(match.group(1)!);
  final cent = int.parse((match.group(2) ?? '0').padRight(2, '0'));
  return pesos * 100 + cent;
}
