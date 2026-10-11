import 'package:flutter/material.dart';

import '../models/pedido.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'common.dart';

enum _ModoPartida { direccion, entrega }

/// Pregunta desde dónde arranca la ruta e inicia la ruta en [appState].
/// Devuelve true si se inició, null si el usuario cerró la hoja.
Future<bool?> mostrarSelectorPartida(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (_) => const _SelectorPartida(),
  );
}

class _SelectorPartida extends StatefulWidget {
  const _SelectorPartida();

  @override
  State<_SelectorPartida> createState() => _SelectorPartidaState();
}

class _SelectorPartidaState extends State<_SelectorPartida> {
  final _formKey = GlobalKey<FormState>();
  final _direccion = TextEditingController();
  final _candidatos = appState.pedidosSeleccionados;
  var _modo = _ModoPartida.direccion;
  Pedido? _pedidoInicial;
  String? _error;

  @override
  void dispose() {
    _direccion.dispose();
    super.dispose();
  }

  void _iniciar() {
    if (_modo == _ModoPartida.direccion) {
      if (!_formKey.currentState!.validate()) return;
      appState.iniciarRuta(direccionPartida: _direccion.text);
    } else {
      if (_pedidoInicial == null) {
        setState(() => _error = 'Elige el punto de entrega donde estás');
        return;
      }
      appState.iniciarRuta(desdePedido: _pedidoInicial);
    }
    Navigator.of(context).pop(true);
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
              '¿Desde dónde inicias la ruta?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            SegmentedButton<_ModoPartida>(
              segments: const [
                ButtonSegment(
                  value: _ModoPartida.direccion,
                  icon: Icon(Icons.place_outlined),
                  label: Text('Otra dirección'),
                ),
                ButtonSegment(
                  value: _ModoPartida.entrega,
                  icon: Icon(Icons.inventory_2_outlined),
                  label: Text('Punto de entrega'),
                ),
              ],
              selected: {_modo},
              onSelectionChanged: (s) => setState(() {
                _modo = s.first;
                _error = null;
              }),
            ),
            const SizedBox(height: 16),
            if (_modo == _ModoPartida.direccion) ...[
              TextFormField(
                controller: _direccion,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _iniciar(),
                decoration: const InputDecoration(
                  hintText: 'Ej: Calle 145 #91-19 (bodega, casa…)',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                validator: (v) => (v ?? '').trim().isEmpty
                    ? 'Ingresa la dirección de salida'
                    : null,
              ),
              const SizedBox(height: 8),
              const Text(
                'No es una entrega: solo se usa para llegar a la primera '
                'parada de la ruta.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ] else ...[
              const Text(
                'Elige la entrega donde te encuentras; será la primera parada.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _candidatos.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _OpcionEntrega(
                    pedido: _candidatos[i],
                    seleccionado: _candidatos[i] == _pedidoInicial,
                    onTap: () => setState(() {
                      _pedidoInicial = _candidatos[i];
                      _error = null;
                    }),
                  ),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 20),
            PrimaryButton(label: 'Iniciar ruta', onPressed: _iniciar),
          ],
        ),
      ),
    );
  }
}

class _OpcionEntrega extends StatelessWidget {
  const _OpcionEntrega({
    required this.pedido,
    required this.seleccionado,
    required this.onTap,
  });

  final Pedido pedido;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      selected: seleccionado,
      tileColor: AppColors.surface,
      selectedTileColor: const Color(0xFFEAF1FF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: seleccionado ? AppColors.primary : AppColors.border,
        ),
      ),
      leading: Icon(
        seleccionado ? Icons.check_circle : Icons.radio_button_unchecked,
        color: seleccionado ? AppColors.primary : AppColors.border,
      ),
      title: Text(pedido.direccion, style: const TextStyle(fontSize: 14)),
      subtitle: Text(pedido.nombre),
    );
  }
}
