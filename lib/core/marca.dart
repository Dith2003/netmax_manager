/// Identidad visual de NET_MAX: colores, datos del negocio y logotipo.
library;

import 'package:flutter/material.dart';

/// Colores de la marca (tomados de la tarjeta de presentación).
abstract final class ColoresNetMax {
  /// Azul marino: "NET", textos y fondos oscuros.
  static const azul = Color(0xFF13294B);

  /// Verde: "MAX", acciones y acentos sobre fondo claro.
  static const verde = Color(0xFF0B7A54);

  /// Verde claro: acentos sobre fondo azul.
  static const verdeClaro = Color(0xFF3FC48D);

  /// Crema: fondo claro de la marca.
  static const crema = Color(0xFFF4EDE1);

  /// Arena: fondo detrás de las tarjetas.
  static const arena = Color(0xFFDCD5C8);

  /// Línea divisoria.
  static const linea = Color(0xFFC7C6C3);

  /// Superficie de tarjetas sobre el fondo crema.
  static const tarjeta = Color(0xFFFFFBF5);
}

/// Datos del negocio que aparecen en reportes y pantallas.
abstract final class DatosNegocio {
  static const nombre = 'NET_MAX';
  static const lema = 'Contigo más lejos, siempre con Fe';
  static const telefono = '771 196 3767';
  static const correo = 'net_max@gmail.com';
  static const direccion = 'Santa Cruz, Nicolás Flores, Hgo. C.P. 42364';
}

/// Rutas de las imágenes del logo.
abstract final class ImagenesMarca {
  /// Torre azul con señal verde (para fondos claros).
  static const logo = 'assets/marca/logo.png';

  /// Torre crema con señal verde claro (para fondos azules).
  static const logoClaro = 'assets/marca/logo_claro.png';
}

/// Logotipo NET_MAX: torre + "NET_MAX" (+ lema opcional).
///
/// [sobreOscuro] usa la versión clara (para fondos azules).
class MarcaNetMax extends StatelessWidget {
  const MarcaNetMax({
    super.key,
    this.alto = 40,
    this.sobreOscuro = false,
    this.conLema = false,
  });

  /// Alto del logo; el texto se escala con él.
  final double alto;
  final bool sobreOscuro;
  final bool conLema;

  @override
  Widget build(BuildContext context) {
    final colorNet = sobreOscuro ? ColoresNetMax.crema : ColoresNetMax.azul;
    final colorMax = sobreOscuro ? ColoresNetMax.verdeClaro : ColoresNetMax.verde;
    final tamano = alto * 0.62;

    final nombre = Text.rich(
      TextSpan(
        style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: tamano,
          fontWeight: FontWeight.w700,
          height: 1,
          letterSpacing: -0.5,
        ),
        children: [
          TextSpan(text: 'NET_', style: TextStyle(color: colorNet)),
          TextSpan(text: 'MAX', style: TextStyle(color: colorMax)),
        ],
      ),
      semanticsLabel: DatosNegocio.nombre,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          sobreOscuro ? ImagenesMarca.logoClaro : ImagenesMarca.logo,
          height: alto,
          excludeFromSemantics: true,
        ),
        SizedBox(width: alto * 0.25),
        Container(width: 1, height: alto * 0.9, color: colorNet.withValues(alpha: 0.3)),
        SizedBox(width: alto * 0.25),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            nombre,
            if (conLema) ...[
              SizedBox(height: alto * 0.08),
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: (alto * 0.24).clamp(10.0, 16.0),
                    color: colorNet,
                    height: 1.1,
                  ),
                  children: [
                    const TextSpan(text: 'Contigo más lejos, siempre con '),
                    TextSpan(
                      text: 'Fe',
                      style: TextStyle(color: colorMax, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
