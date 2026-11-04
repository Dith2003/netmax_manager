/// Valores fijos que se guardan como texto en la base de datos.
library;

enum RolUsuario { propietario, admin }

/// [otro]: contratación personalizada; la descripción va en
/// `clientes.tipo_contratacion_detalle`.
enum TipoContratacion { compraEquipo, equipoPropio, equipoPrestado, otro }

enum EstadoCliente { activo, suspendido, cancelado }

enum PropiedadEquipo { cliente, netmax }

enum MetodoPago { efectivo, transferencia, deposito, otro }
