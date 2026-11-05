# Lista de pruebas — NET_MAX 1.0.0 (versión de prueba)

Marca cada punto en Windows (W) y en Android (A). Si algo falla anota qué hiciste, qué esperabas y
qué pasó (una captura ayuda mucho) para corregirlo en la siguiente ronda.

> Consejo: haz las pruebas con datos de ejemplo. Si usas tu información real, crea un respaldo
> antes de empezar.

## 1. Instalación y acceso
| | Prueba | W | A |
|---|---|---|---|
| 1.1 | El instalador / APK se instala y la app abre con el logo de NET_MAX | ☐ | ☐ |
| 1.2 | El ícono y el nombre "NET_MAX" aparecen en el menú Inicio / en el celular | ☐ | ☐ |
| 1.3 | La primera vez pide crear tu usuario y PIN; al crearlo entra a Inicio | ☐ | ☐ |
| 1.4 | Al cerrar y abrir la app pide el PIN; con un PIN incorrecto avisa | ☐ | ☐ |
| 1.5 | "Cerrar sesión" regresa a la pantalla de acceso | ☐ | ☐ |
| 1.6 | La versión 1.0.0 se ve en la pantalla de acceso y en Respaldos | ☐ | ☐ |

## 2. Configuración y usuarios
| | Prueba | W | A |
|---|---|---|---|
| 2.1 | Crear un plan nuevo (p. ej. 20 Mbps $350) y editarlo | ☐ | ☐ |
| 2.2 | Desactivar un plan: ya no aparece al registrar un cliente nuevo | ☐ | ☐ |
| 2.3 | Crear un usuario con el perfil Administrador y entrar con él | ☐ | ☐ |
| 2.4 | Con el Administrador no aparece Configuración ni "Cancelar pago" | ☐ | ☐ |
| 2.5 | Quitar un permiso a un usuario (queda "Personalizado") y comprobar que ya no puede hacerlo | ☐ | ☐ |
| 2.6 | Cambiar el PIN de un usuario y entrar con el PIN nuevo | ☐ | ☐ |

## 3. Clientes
| | Prueba | W | A |
|---|---|---|---|
| 3.1 | Registrar un cliente con equipo propio | ☐ | ☐ |
| 3.2 | Registrar un cliente con "Otro (personalizado)" y su descripción | ☐ | ☐ |
| 3.3 | Registrar un cliente con "Crear plan nuevo…" desde el formulario | ☐ | ☐ |
| 3.4 | Buscar por nombre, zona o teléfono (con y sin acentos) | ☐ | ☐ |
| 3.5 | Editar, suspender, reactivar y cancelar desde la tabla de clientes | ☐ | ☐ |
| 3.6 | En la ficha: pestañas Pagos / Instalaciones / Equipos / Historial | ☐ | ☐ |
| 3.7 | Agregar una instalación y un equipo prestado | ☐ | ☐ |
| 3.8 | El historial muestra "por <tu nombre>" en los cambios de estado | ☐ | ☐ |

## 4. Pagos y comprobantes
| | Prueba | W | A |
|---|---|---|---|
| 4.1 | Registrar un pago de una mensualidad: el folio aparece en gris y no se puede editar | ☐ | ☐ |
| 4.2 | Pago adelantado de 3 meses: la vista previa reparte bien los meses | ☐ | ☐ |
| 4.3 | Abono parcial: el mes queda "Con abono" y el resto se debe | ☐ | ☐ |
| 4.4 | Pago por transferencia con referencia bancaria | ☐ | ☐ |
| 4.5 | El comprobante (1/3 de hoja) se ve bien, se imprime y se guarda en PDF | ☐ | ☐ |
| 4.6 | Cancelar un pago: los meses vuelven a quedar pendientes y el comprobante dice CANCELADO | ☐ | ☐ |

## 5. Estado de cuenta y adeudos
| | Prueba | W | A |
|---|---|---|---|
| 5.1 | Marcar un mes como cortesía y quitarla | ☐ | ☐ |
| 5.2 | Agregar un cargo extra (reconexión) y cobrarlo con un pago | ☐ | ☐ |
| 5.3 | Adeudos muestra a los clientes con meses vencidos y el total | ☐ | ☐ |

## 6. Inicio y reportes
| | Prueba | W | A |
|---|---|---|---|
| 6.1 | Los indicadores de Inicio coinciden con los pagos registrados | ☐ | ☐ |
| 6.2 | Las gráficas de cobranza y actividad se ven y responden al pasar el mouse / tocar | ☐ | ☐ |
| 6.3 | Los 4 reportes PDF se generan, se imprimen y se guardan | ☐ | ☐ |
| 6.4 | Comprobantes de pago del mes: se abren y descargan | ☐ | ☐ |

## 7. Respaldos
| | Prueba | W | A |
|---|---|---|---|
| 7.1 | Crear un respaldo (Windows: guardar como; Android: compartir) | ☐ | ☐ |
| 7.2 | Restaurar ese respaldo: la información vuelve y la app pide el PIN | ☐ | ☐ |
| 7.3 | Pasar un respaldo de Windows al celular (o al revés) y restaurarlo | ☐ | ☐ |

## 8. Escritorio (solo Windows)
| | Prueba | W |
|---|---|---|
| 8.1 | Zoom con los botones del panel y con Ctrl + / Ctrl − / Ctrl 0 | ☐ |
| 8.2 | Con zoom de 80 % todos los botones responden | ☐ |
| 8.3 | Al hacer la ventana angosta el panel se compacta y luego cambia a barra inferior | ☐ |
| 8.4 | Actualizar: instalar la misma versión encima conserva la información | ☐ |
