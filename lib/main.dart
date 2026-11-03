import 'package:flutter/material.dart';

import 'core/dinero.dart';
import 'data/db/database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(NetMaxApp(db: AppDatabase()));
}

class NetMaxApp extends StatelessWidget {
  const NetMaxApp({super.key, required this.db});

  final AppDatabase db;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NetMAX Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: VerificacionScreen(db: db),
    );
  }
}

/// Pantalla temporal del Sprint 1: confirma que la base de datos se creó.
/// Se reemplaza por el Dashboard en el Sprint 5.
class VerificacionScreen extends StatefulWidget {
  const VerificacionScreen({super.key, required this.db});

  final AppDatabase db;

  @override
  State<VerificacionScreen> createState() => _VerificacionScreenState();
}

class _VerificacionScreenState extends State<VerificacionScreen> {
  late final Future<List<Plan>> _planes;

  @override
  void initState() {
    super.initState();
    _planes = widget.db.select(widget.db.planes).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NetMAX Manager')),
      body: Center(
        child: FutureBuilder<List<Plan>>(
          future: _planes,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error al abrir la base de datos:\n${snapshot.error}'),
              );
            }
            if (!snapshot.hasData) return const CircularProgressIndicator();
            final planes = snapshot.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 72),
                const SizedBox(height: 16),
                Text('Base de datos lista',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                for (final p in planes)
                  Text('Plan ${p.nombre}: ${formatoDinero(p.precioBase)} al mes'),
              ],
            );
          },
        ),
      ),
    );
  }
}
