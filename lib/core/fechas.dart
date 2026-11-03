/// Utilidades de fechas en español (sin depender del paquete intl).
library;

const _mesesCortos = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

/// Quita la hora: 2026-11-03 18:20 -> 2026-11-03 00:00.
DateTime soloFecha(DateTime f) => DateTime(f.year, f.month, f.day);

/// "03/11/2026"
String formatoFecha(DateTime f) =>
    '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';

/// "3 nov 2026"
String formatoFechaCorta(DateTime f) => '${f.day} ${_mesesCortos[f.month - 1]} ${f.year}';
