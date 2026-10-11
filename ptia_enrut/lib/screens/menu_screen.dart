import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'login_screen.dart';
import 'secundarias.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key, required this.onCerrarMenu});

  final VoidCallback onCerrarMenu;

  void _abrir(BuildContext context, Widget pantalla) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => pantalla));
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    appState.cerrarSesion();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 24),
      children: [
        SoftCard(
          radius: 12,
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              IconBoxButton(
                icon: Icons.menu,
                tooltip: 'Volver al inicio',
                onPressed: onCerrarMenu,
              ),
              const SizedBox(width: 12),
              const Text(
                'Menú',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _MenuItem(
          icon: Icons.person_outline,
          label: 'Perfil Repartidor',
          bold: true,
          onTap: () => _abrir(context, const PerfilScreen()),
        ),
        _MenuItem(
          icon: Icons.inventory_2_outlined,
          label: 'Entregas realizadas',
          onTap: () => _abrir(context, const EntregasRealizadasScreen()),
        ),
        _MenuItem(
          icon: Icons.chat_bubble_outline,
          label: 'Mensajes',
          onTap: () => _abrir(context, const MensajesScreen()),
        ),
        _MenuItem(
          icon: Icons.info_outline,
          label: 'Acerca de la aplicación',
          onTap: () => mostrarAcercaDe(context),
        ),
        _MenuItem(
          icon: Icons.logout,
          label: 'Cerrar Sesión',
          color: AppColors.primary,
          bold: true,
          onTap: () => _cerrarSesion(context),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.text,
    this.bold = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 13.5,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
