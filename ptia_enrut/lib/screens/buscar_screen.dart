import 'package:flutter/material.dart';

import '../models/pedido.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Busca pedidos (pendientes y entregados) por dirección o nombre.
class BuscarScreen extends StatefulWidget {
  const BuscarScreen({super.key});

  @override
  State<BuscarScreen> createState() => _BuscarScreenState();
}

class _BuscarScreenState extends State<BuscarScreen> {
  String _consulta = '';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final q = _consulta.trim().toLowerCase();
        final todos = [...appState.pedidos, ...appState.entregados];
        final resultados = q.isEmpty
            ? todos
            : todos
                  .where(
                    (p) =>
                        p.direccion.toLowerCase().contains(q) ||
                        p.nombre.toLowerCase().contains(q),
                  )
                  .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 18, 16, 12),
              child: Text(
                'Buscar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (v) => setState(() => _consulta = v),
                decoration: const InputDecoration(
                  hintText: 'Dirección o nombre del cliente',
                  prefixIcon: Icon(Icons.search, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: resultados.isEmpty
                  ? Center(
                      child: Text(
                        todos.isEmpty
                            ? 'Aún no hay pedidos registrados'
                            : 'Sin resultados para "$_consulta"',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: resultados.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _Resultado(resultados[i]),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _Resultado extends StatelessWidget {
  const _Resultado(this.pedido);

  final Pedido pedido;

  @override
  Widget build(BuildContext context) {
    final entregado = pedido.estado == EstadoPedido.entregado;
    return ListTile(
      tileColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      leading: Icon(
        entregado ? Icons.check_circle : Icons.local_shipping_outlined,
        color: entregado ? Colors.green : AppColors.primary,
      ),
      title: Text(pedido.direccion, style: const TextStyle(fontSize: 14)),
      subtitle: Text(pedido.nombre),
      trailing: Text(
        pedido.estado.label,
        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
    );
  }
}
