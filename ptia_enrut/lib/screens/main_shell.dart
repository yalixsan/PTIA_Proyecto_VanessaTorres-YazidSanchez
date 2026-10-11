import 'package:flutter/material.dart';

import '../widgets/app_bottom_nav.dart';
import 'buscar_screen.dart';
import 'home_screen.dart';
import 'menu_screen.dart';

/// Contenedor principal con las tres pestañas de la barra inferior.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;

  void _irA(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [
            HomeScreen(onAbrirMenu: () => _irA(2)),
            const BuscarScreen(),
            MenuScreen(onCerrarMenu: () => _irA(0)),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: _index, onTap: _irA),
    );
  }
}

/// Para pantallas apiladas encima del shell (Lista, Mapa…): vuelve al shell
/// en la pestaña indicada.
void irAPestana(BuildContext context, int index) {
  Navigator.of(context).pushAndRemoveUntil(
    PageRouteBuilder(
      pageBuilder: (_, _, _) => MainShell(initialIndex: index),
      transitionDuration: Duration.zero,
    ),
    (_) => false,
  );
}
