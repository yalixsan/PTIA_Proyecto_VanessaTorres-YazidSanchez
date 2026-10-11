import 'package:flutter/material.dart';

import '../models/pedido.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/common.dart';
import '../widgets/selector_partida.dart';
import 'main_shell.dart';
import 'mapa_rutas_screen.dart';

class ListaEntregasScreen extends StatefulWidget {
  const ListaEntregasScreen({super.key});

  @override
  State<ListaEntregasScreen> createState() => _ListaEntregasScreenState();
}

class _ListaEntregasScreenState extends State<ListaEntregasScreen> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _iniciarRuta() async {
    if (appState.seleccionados.isEmpty) {
      mostrarMensaje(context, 'Selecciona al menos un pedido para iniciar.');
      return;
    }
    final iniciada = await mostrarSelectorPartida(context);
    if (iniciada != true || !mounted) return;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const MapaRutasScreen()));
  }

  Future<void> _agregarPedido() async {
    final pedido = await showModalBottomSheet<Pedido>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => const _FormularioPedido(),
    );
    if (pedido != null && mounted) {
      mostrarMensaje(context, 'Pedido agregado: ${pedido.direccion}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: appState,
          builder: (context, _) {
            final pedidos = appState.pedidos;
            return Column(
              children: [
                ScreenHeader(
                  title: 'Lista de Entregas',
                  icon: Icons.menu,
                  iconTooltip: 'Menú',
                  onIconPressed: () => irAPestana(context, 2),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SoftCard(
                    radius: 10,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    onTap: _agregarPedido,
                    child: const Center(
                      child: Text(
                        'Agrega el pedido +',
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  pedidos.isEmpty
                      ? 'Aún no tienes pedidos en la lista'
                      : 'Selecciona los pedidos que va a entregar '
                            '(${appState.seleccionados.length}/${pedidos.length})',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: pedidos.isEmpty
                      ? const _ListaVacia()
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ListView.separated(
                                  controller: _scroll,
                                  padding: const EdgeInsets.fromLTRB(
                                    2,
                                    4,
                                    4,
                                    12,
                                  ),
                                  itemCount: pedidos.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 14),
                                  itemBuilder: (_, i) =>
                                      _PedidoItem(pedido: pedidos[i]),
                                ),
                              ),
                              const SizedBox(width: 6),
                              _BarraScroll(controller: _scroll),
                            ],
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 10, 32, 14),
                  child: PrimaryButton(
                    label: 'Inicia tu ruta',
                    onPressed: pedidos.isEmpty ? null : _iniciarRuta,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (i) => irAPestana(context, i),
      ),
    );
  }
}

class _PedidoItem extends StatelessWidget {
  const _PedidoItem({required this.pedido});

  final Pedido pedido;

  @override
  Widget build(BuildContext context) {
    final seleccionado = appState.seleccionados.contains(pedido.id);
    const estilo = TextStyle(fontSize: 12.5, height: 1.45);

    return Row(
      children: [
        Expanded(
          child: SoftCard(
            radius: 10,
            color: seleccionado ? const Color(0xFFEAF1FF) : AppColors.surface,
            borderColor: seleccionado ? AppColors.primary : AppColors.border,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            onTap: () => appState.alternarSeleccion(pedido),
            child: Row(
              children: [
                Icon(
                  seleccionado
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 18,
                  color: seleccionado ? AppColors.primary : AppColors.border,
                ),
                Expanded(
                  child: Text(
                    'Dirección: ${pedido.direccion}\n'
                    'Nombre: ${pedido.nombre}\n'
                    'Rapida entrega: ${pedido.rapida ? 'sí' : 'No'}',
                    textAlign: TextAlign.center,
                    style: estilo,
                  ),
                ),
                const SizedBox(width: 18),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        IconBoxButton(
          icon: Icons.close,
          size: 26,
          tooltip: 'Eliminar pedido',
          onPressed: () => appState.eliminarPedido(pedido),
        ),
      ],
    );
  }
}

/// Barra de desplazamiento con flechas, como en el diseño.
class _BarraScroll extends StatelessWidget {
  const _BarraScroll({required this.controller});

  final ScrollController controller;

  void _mover(double delta) {
    if (!controller.hasClients) return;
    final p = controller.position;
    controller.animateTo(
      (p.pixels + delta).clamp(0, p.maxScrollExtent),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          _Flecha(icon: Icons.arrow_drop_up, onTap: () => _mover(-140)),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => ListenableBuilder(
                listenable: controller,
                builder: (context, _) {
                  final alto = constraints.maxHeight;
                  var fraccion = 1.0;
                  var posicion = 0.0;
                  if (controller.hasClients &&
                      controller.position.hasContentDimensions) {
                    final p = controller.position;
                    final total = p.viewportDimension + p.maxScrollExtent;
                    fraccion = (p.viewportDimension / total).clamp(0.15, 1.0);
                    posicion = p.maxScrollExtent == 0
                        ? 0
                        : (p.pixels / p.maxScrollExtent).clamp(0.0, 1.0);
                  }
                  final altoThumb = alto * fraccion;
                  return Stack(
                    children: [
                      Positioned(
                        top: (alto - altoThumb) * posicion,
                        left: 3,
                        right: 3,
                        height: altoThumb,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          _Flecha(icon: Icons.arrow_drop_down, onTap: () => _mover(140)),
        ],
      ),
    );
  }
}

class _Flecha extends StatelessWidget {
  const _Flecha({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 18,
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}

class _ListaVacia extends StatelessWidget {
  const _ListaVacia();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.border),
            SizedBox(height: 12),
            Text(
              'Usa "Agrega el pedido +" para añadir las direcciones '
              'que vas a entregar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormularioPedido extends StatefulWidget {
  const _FormularioPedido();

  @override
  State<_FormularioPedido> createState() => _FormularioPedidoState();
}

class _FormularioPedidoState extends State<_FormularioPedido> {
  final _formKey = GlobalKey<FormState>();
  final _direccion = TextEditingController();
  final _nombre = TextEditingController();
  bool _rapida = false;

  @override
  void dispose() {
    _direccion.dispose();
    _nombre.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    final pedido = appState.agregarPedido(
      direccion: _direccion.text,
      nombre: _nombre.text,
      rapida: _rapida,
    );
    Navigator.of(context).pop(pedido);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nuevo pedido',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _direccion,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Dirección (ej: Carrera 103A #141-45)',
              ),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Ingresa la dirección' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nombre,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _guardar(),
              decoration: const InputDecoration(
                hintText: 'Nombre de quien recibe',
              ),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Ingresa el nombre' : null,
            ),
            const SizedBox(height: 4),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Rápida entrega'),
              subtitle: const Text(
                'Se prioriza al inicio de la ruta',
                style: TextStyle(fontSize: 12),
              ),
              value: _rapida,
              onChanged: (v) => setState(() => _rapida = v),
            ),
            const SizedBox(height: 8),
            PrimaryButton(label: 'Agregar', onPressed: _guardar),
          ],
        ),
      ),
    );
  }
}
