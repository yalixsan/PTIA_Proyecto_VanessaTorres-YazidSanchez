import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/common.dart';
import 'main_shell.dart';

/// Estructura común para las pantallas abiertas desde el Menú.
class _PantallaMenu extends StatelessWidget {
  const _PantallaMenu({required this.titulo, required this.child});

  final String titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: titulo,
              icon: Icons.arrow_back,
              iconTooltip: 'Volver',
              onIconPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (i) => irAPestana(context, i),
      ),
    );
  }
}

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _PantallaMenu(
      titulo: 'Perfil Repartidor',
      child: ListenableBuilder(
        listenable: appState,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.surface,
              child: Icon(Icons.person, size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Text(
              appState.email ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 24),
            _Dato('Código de empresa', appState.codigoEmpresa ?? 'Sin asignar'),
            _Dato('Pedidos en lista', '${appState.pedidos.length}'),
            _Dato('Paradas en ruta', '${appState.ruta.length}'),
            _Dato('Entregas realizadas', '${appState.entregados.length}'),
          ],
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato(this.etiqueta, this.valor);

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        radius: 10,
        child: Row(
          children: [
            Expanded(
              child: Text(
                etiqueta,
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ),
            Text(valor, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class EntregasRealizadasScreen extends StatelessWidget {
  const EntregasRealizadasScreen({super.key});

  String _hora(DateTime? t) => t == null
      ? ''
      : '${t.hour.toString().padLeft(2, '0')}:'
            '${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return _PantallaMenu(
      titulo: 'Entregas realizadas',
      child: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final entregados = appState.entregados;
          if (entregados.isEmpty) {
            return const Center(
              child: Text(
                'Aún no has completado entregas hoy',
                style: TextStyle(color: AppColors.textMuted),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entregados.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final p = entregados[i];
              return ListTile(
                tileColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: AppColors.border),
                ),
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(p.direccion),
                subtitle: Text(p.nombre),
                trailing: Text(_hora(p.entregadoEn)),
              );
            },
          );
        },
      ),
    );
  }
}

class MensajesScreen extends StatelessWidget {
  const MensajesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PantallaMenu(
      titulo: 'Mensajes',
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 48,
                color: AppColors.border,
              ),
              SizedBox(height: 12),
              Text(
                'No tienes mensajes de tu empresa por ahora.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void mostrarAcercaDe(BuildContext context) {
  showAboutDialog(
    context: context,
    applicationName: 'Enrut.AI',
    applicationVersion: '1.0.0',
    applicationIcon: const Icon(
      Icons.route,
      color: AppColors.primary,
      size: 36,
    ),
    children: const [
      Text(
        'Optimización de rutas de entrega para repartidores independientes '
        'y pequeñas empresas de mensajería en zonas de alta densidad, '
        'como la localidad de Suba en Bogotá.\n\n'
        'Proyecto de curso PTIA – Escuela Colombiana de Ingeniería '
        'Julio Garavito.\nVanessa Torres · Yazid Sánchez',
      ),
    ],
  );
}
