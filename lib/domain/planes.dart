/// Reglas y validaciones de los planes de internet (lógica pura).
library;

/// Datos que captura el formulario de plan.
class DatosPlan {
  const DatosPlan({
    required this.nombre,
    required this.velocidadMbps,
    required this.precioBase,
  });

  final String nombre;
  final int velocidadMbps;

  /// Precio sugerido para los clientes nuevos, en centavos.
  final int precioBase;
}

String? validarNombrePlan(String? valor) {
  final v = valor?.trim() ?? '';
  if (v.isEmpty) return 'Escribe el nombre del plan';
  if (v.length > 40) return 'Máximo 40 caracteres';
  return null;
}

/// Velocidad en Mbps: número entero de 1 a 1000.
String? validarVelocidad(String? valor) {
  final v = int.tryParse(valor?.trim() ?? '');
  if (v == null) return 'Escribe la velocidad en Mbps';
  if (v < 1 || v > 1000) return 'Entre 1 y 1000 Mbps';
  return null;
}

/// Nombre sugerido para un plan nuevo a partir de su velocidad: "20 Mbps".
String nombreSugeridoPlan(int velocidadMbps) => '$velocidadMbps Mbps';

/// Un plan solo se puede desactivar si queda al menos otro activo
/// (el formulario de cliente siempre necesita un plan para elegir).
bool sePuedeDesactivarPlan({required int activos}) => activos > 1;
