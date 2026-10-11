import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/pedido.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/common.dart';
import 'main_shell.dart';

class MapaRutasScreen extends StatelessWidget {
  const MapaRutasScreen({super.key});

  Future<void> _confirmarEntrega(BuildContext context, Pedido pedido) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Pedido entregado?'),
        content: Text('${pedido.direccion}\n${pedido.nombre}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Marcar entregado'),
          ),
        ],
      ),
    );
    if (ok == true) appState.marcarEntregado(pedido);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: appState,
          builder: (context, _) {
            final ruta = appState.ruta;
            return Column(
              children: [
                ScreenHeader(
                  title: 'Mapa de Rutas',
                  icon: Icons.arrow_back,
                  iconTooltip: 'Volver',
                  onIconPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    children: [
                      SoftCard(
                        radius: 18,
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Zona: Suba (Optimizado)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                                if (ruta.isNotEmpty)
                                  Text(
                                    '≈ ${appState.distanciaRutaKm.toStringAsFixed(1)} km',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                              ],
                            ),
                            AspectRatio(
                              aspectRatio: 1.45,
                              child: ruta.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'Sin paradas pendientes',
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    )
                                  : CustomPaint(
                                      painter: _RutaPainter(ruta),
                                      size: Size.infinite,
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      SoftCard(
                        radius: 18,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.format_list_bulleted,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Pedidos que hacen falta:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: AppColors.border, height: 20),
                            if (ruta.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  '¡Ruta completada! 🎉',
                                  style: TextStyle(fontSize: 13),
                                ),
                              )
                            else ...[
                              for (final (i, p) in ruta.indexed)
                                InkWell(
                                  borderRadius: BorderRadius.circular(6),
                                  onTap: () => _confirmarEntrega(context, p),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${i + 1}. ${p.direccion} '
                                            '(${p.estado.label})',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: i == 0
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        if (p.rapida)
                                          const Tooltip(
                                            message: 'Rápida entrega',
                                            child: Icon(
                                              Icons.bolt,
                                              size: 16,
                                              color: Color(0xFFF59E0B),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              const Text(
                                'Toca un pedido para marcarlo como entregado.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: null,
        onTap: (i) => irAPestana(context, i),
      ),
    );
  }
}

/// Dibuja las paradas (A, B, C…) en el orden optimizado.
class _RutaPainter extends CustomPainter {
  _RutaPainter(this.ruta);

  final List<Pedido> ruta;

  static const _radio = 11.0;

  @override
  void paint(Canvas canvas, Size size) {
    final puntos = _proyectar(size);

    final linea = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.85)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    if (puntos.length > 1) {
      final path = Path()..moveTo(puntos.first.dx, puntos.first.dy);
      for (final p in puntos.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, linea);
    }

    final relleno = Paint()..color = Colors.white;
    final borde = Paint()
      ..color = AppColors.text
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final (i, p) in puntos.indexed) {
      canvas
        ..drawCircle(p, _radio, relleno)
        ..drawCircle(p, _radio, borde);
      final tp = TextPainter(
        text: TextSpan(
          text: _etiqueta(i),
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }
  }

  /// Convierte lat/lng a coordenadas del lienzo conservando proporciones.
  List<Offset> _proyectar(Size size) {
    const margen = _radio + 8;
    final ancho = size.width - margen * 2;
    final alto = size.height - margen * 2;

    final lats = ruta.map((p) => p.lat);
    final lngs = ruta.map((p) => p.lng);
    final minLat = lats.reduce(math.min), maxLat = lats.reduce(math.max);
    final minLng = lngs.reduce(math.min), maxLng = lngs.reduce(math.max);
    final rangoLat = math.max(maxLat - minLat, 1e-6);
    final rangoLng = math.max(maxLng - minLng, 1e-6);
    final escala = math.min(ancho / rangoLng, alto / rangoLat);

    final offsetX = margen + (ancho - rangoLng * escala) / 2;
    final offsetY = margen + (alto - rangoLat * escala) / 2;

    if (ruta.length == 1) return [size.center(Offset.zero)];
    final puntos = [
      for (final p in ruta)
        Offset(
          offsetX + (p.lng - minLng) * escala,
          // El norte queda arriba.
          offsetY + (maxLat - p.lat) * escala,
        ),
    ];
    _separar(puntos, size);
    return puntos;
  }

  /// Aparta los nodos que quedarían encimados para que se lean las letras.
  void _separar(List<Offset> puntos, Size size) {
    const minimo = _radio * 2 + 4;
    for (var iter = 0; iter < 30; iter++) {
      var movio = false;
      for (var i = 0; i < puntos.length; i++) {
        for (var j = i + 1; j < puntos.length; j++) {
          var d = puntos[j] - puntos[i];
          if (d.distance >= minimo) continue;
          if (d.distance < 0.01) {
            d = Offset(math.cos(j.toDouble()), math.sin(j.toDouble()));
          }
          final empuje = d / d.distance * ((minimo - d.distance) / 2);
          puntos[i] = _limitar(puntos[i] - empuje, size);
          puntos[j] = _limitar(puntos[j] + empuje, size);
          movio = true;
        }
      }
      if (!movio) break;
    }
  }

  Offset _limitar(Offset p, Size size) => Offset(
    p.dx.clamp(_radio, size.width - _radio),
    p.dy.clamp(_radio, size.height - _radio),
  );

  String _etiqueta(int i) {
    var n = i;
    var s = '';
    do {
      s = String.fromCharCode(65 + n % 26) + s;
      n = n ~/ 26 - 1;
    } while (n >= 0);
    return s;
  }

  @override
  bool shouldRepaint(_RutaPainter old) => true;
}
