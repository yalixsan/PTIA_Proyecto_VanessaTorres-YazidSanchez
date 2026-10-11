import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'lista_entregas_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onAbrirMenu});

  final VoidCallback onAbrirMenu;

  void _abrirLista(BuildContext context, {required bool deEmpresa}) {
    if (deEmpresa) appState.cargarPedidosEmpresa();
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ListaEntregasScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(
            children: [
              IconBoxButton(
                icon: Icons.menu,
                tooltip: 'Menú',
                onPressed: onAbrirMenu,
              ),
              const Expanded(
                child: Text(
                  'Home',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
            child: Column(
              children: [
                const Text(
                  '¿Cómo gestionarás tus entregas hoy?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontStyle: FontStyle.italic,
                    fontSize: 17,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 28),
                _OpcionCard(
                  texto: 'Agregar manualmente\nlos paquetes',
                  icono: Icons.edit_note,
                  onTap: () => _abrirLista(context, deEmpresa: false),
                ),
                const SizedBox(height: 14),
                _OpcionCard(
                  texto: 'Paquetes asignados\npor tu empresa',
                  icono: Icons.business_center_outlined,
                  onTap: () => _abrirLista(context, deEmpresa: true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OpcionCard extends StatelessWidget {
  const _OpcionCard({
    required this.texto,
    required this.icono,
    required this.onTap,
  });

  final String texto;
  final IconData icono;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: SoftCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Icon(icono, color: AppColors.primary.withValues(alpha: 0.7)),
            Expanded(
              child: Text(
                texto,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}
