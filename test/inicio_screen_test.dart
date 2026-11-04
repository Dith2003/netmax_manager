import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netmax_manager/core/mes.dart';
import 'package:netmax_manager/data/db/database.dart';
import 'package:netmax_manager/domain/dashboard.dart';
import 'package:netmax_manager/main.dart';
import 'package:netmax_manager/providers/providers.dart';
import 'package:netmax_manager/providers/sesion.dart';

final _propietario = Usuario(
  id: 1,
  nombre: 'Edith',
  usuario: 'edith',
  pinHash: '',
  rol: RolUsuario.propietario,
  activo: true,
  creadoEn: DateTime(2026, 11, 1),
);

/// La app abre en Inicio con el resumen (datos simulados) y navega a Clientes.
void main() {
  final nov = Mes(2026, 11);
  final resumen = ResumenDashboard(
    mes: nov,
    cobradoMes: 125000,
    pagosMes: 4,
    esperadoMes: 100000,
    cubiertoMes: 75000,
    porCobrar: 55000,
    clientesConAdeudo: 2,
    clientesPorEstado: const {EstadoCliente.activo: 12, EstadoCliente.suspendido: 1},
    proximosVencimientos: [
      (
        clienteId: 3,
        cliente: 'Beto Ruiz',
        estado: EstadoCliente.activo,
        mes: nov,
        vencimiento: DateTime(2026, 11, 8),
        monto: 25000,
        pagado: 10000,
        esCortesia: false,
      ),
    ],
    pagosRecientes: [
      (clienteId: 1, cliente: 'Ana López', fecha: DateTime(2026, 11, 2), monto: 50000),
    ],
  );

  testWidgets('muestra indicadores, medidor, vencimientos y pagos recientes', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        resumenProvider.overrideWith((ref) => Stream.value(resumen)),
        clientesProvider.overrideWith((ref, filtro) => Stream.value(<Cliente>[])),
        ultimoRespaldoProvider.overrideWith((ref) => Stream.value(null)),
        // Sesión abierta (la pantalla de acceso se prueba en sesion_test.dart).
        sesionInicialProvider.overrideWithValue(_propietario),
        usuariosProvider.overrideWith((ref) => Stream.value([_propietario])),
      ],
      child: const NetMaxApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Cobrado en noviembre 2026'), findsOneWidget);
    expect(find.text(r'$1,250.00'), findsOneWidget);
    expect(find.text('4 pagos recibidos'), findsOneWidget);
    expect(find.text(r'$550.00'), findsOneWidget);
    expect(find.text('2 clientes con adeudo'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('1 suspendido · 0 cancelados'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text(r'$750.00 de $1,000.00'), findsOneWidget);
    // Acciones rápidas.
    expect(find.text('Registrar pago'), findsOneWidget);
    expect(find.text('Nuevo cliente'), findsOneWidget);
    expect(find.text('Beto Ruiz'), findsOneWidget);
    expect(find.text(r'$150.00'), findsOneWidget);
    expect(find.text('Ana López'), findsOneWidget);
    // Nunca se ha hecho un respaldo: aparece el recordatorio.
    expect(find.text('Haz un respaldo de tu información'), findsOneWidget);

    // Navegar a Clientes con la barra inferior.
    await tester.tap(find.text('Clientes').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('Aún no hay clientes'), findsOneWidget);
  });
}
