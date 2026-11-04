/// Un mes de servicio (año + mes), por ejemplo noviembre 2026.
/// En la base de datos se guarda como texto 'YYYY-MM'.
class Mes implements Comparable<Mes> {
  final int anio;
  final int mes;

  Mes(this.anio, this.mes) {
    if (mes < 1 || mes > 12) {
      throw ArgumentError.value(mes, 'mes', 'debe estar entre 1 y 12');
    }
  }

  factory Mes.deFecha(DateTime fecha) => Mes(fecha.year, fecha.month);

  /// Lee el formato 'YYYY-MM'.
  factory Mes.parse(String texto) {
    final match = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(texto);
    if (match == null) throw FormatException('Mes no válido', texto);
    return Mes(int.parse(match.group(1)!), int.parse(match.group(2)!));
  }

  Mes siguiente() => mes == 12 ? Mes(anio + 1, 1) : Mes(anio, mes + 1);

  /// Fecha en que vence este mes para un cliente con [diaCorte] (1-28).
  DateTime fechaVencimiento(int diaCorte) {
    if (diaCorte < 1 || diaCorte > 28) {
      throw ArgumentError.value(diaCorte, 'diaCorte', 'debe estar entre 1 y 28');
    }
    return DateTime(anio, mes, diaCorte);
  }

  static const _nombres = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio',
    'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  /// "noviembre 2026"
  String get nombre => '${_nombres[mes - 1]} $anio';

  /// "nov 2026"
  String get nombreCorto => '${_nombres[mes - 1].substring(0, 3)} $anio';

  @override
  int compareTo(Mes other) =>
      anio != other.anio ? anio.compareTo(other.anio) : mes.compareTo(other.mes);

  @override
  bool operator ==(Object other) =>
      other is Mes && other.anio == anio && other.mes == mes;

  @override
  int get hashCode => Object.hash(anio, mes);

  /// 'YYYY-MM'
  @override
  String toString() => '$anio-${mes.toString().padLeft(2, '0')}';
}
