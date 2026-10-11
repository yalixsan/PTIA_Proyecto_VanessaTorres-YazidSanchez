import 'dart:math' as math;

import '../models/pedido.dart';

class RutaOptimizada {
  const RutaOptimizada(this.paradas, this.distanciaKm);

  final List<Pedido> paradas;
  final double distanciaKm;
}

/// Optimizador de rutas (problema tipo TSP/VRP de un solo vehículo).
///
/// 1. Separa los pedidos de "rápida entrega" para atenderlos primero.
/// 2. Construye cada tramo con la heurística del vecino más cercano.
/// 3. Mejora cada tramo con 2-opt hasta que no haya cruces que acortar.
class RouteOptimizer {
  static RutaOptimizada optimizar(
    List<Pedido> pedidos, {
    required ({double lat, double lng}) inicio,
  }) {
    if (pedidos.isEmpty) return const RutaOptimizada([], 0);

    final urgentes = pedidos.where((p) => p.rapida).toList();
    final normales = pedidos.where((p) => !p.rapida).toList();

    final tramo1 = _dosOpt(_vecinoMasCercano(urgentes, inicio), inicio);
    final inicio2 = tramo1.isEmpty
        ? inicio
        : (lat: tramo1.last.lat, lng: tramo1.last.lng);
    final tramo2 = _dosOpt(_vecinoMasCercano(normales, inicio2), inicio2);

    final ruta = [...tramo1, ...tramo2];
    return RutaOptimizada(ruta, _longitud(ruta, inicio));
  }

  static List<Pedido> _vecinoMasCercano(
    List<Pedido> pendientes,
    ({double lat, double lng}) inicio,
  ) {
    final restantes = [...pendientes];
    final orden = <Pedido>[];
    var actual = inicio;
    while (restantes.isNotEmpty) {
      restantes.sort(
        (a, b) => distanciaKm(actual, (
          lat: a.lat,
          lng: a.lng,
        )).compareTo(distanciaKm(actual, (lat: b.lat, lng: b.lng))),
      );
      final siguiente = restantes.removeAt(0);
      orden.add(siguiente);
      actual = (lat: siguiente.lat, lng: siguiente.lng);
    }
    return orden;
  }

  static List<Pedido> _dosOpt(
    List<Pedido> ruta,
    ({double lat, double lng}) inicio,
  ) {
    if (ruta.length < 3) return ruta;
    var mejor = [...ruta];
    var mejorLongitud = _longitud(mejor, inicio);
    var mejoro = true;
    while (mejoro) {
      mejoro = false;
      for (var i = 0; i < mejor.length - 1; i++) {
        for (var k = i + 1; k < mejor.length; k++) {
          final candidata = [
            ...mejor.sublist(0, i),
            ...mejor.sublist(i, k + 1).reversed,
            ...mejor.sublist(k + 1),
          ];
          final longitud = _longitud(candidata, inicio);
          if (longitud + 1e-9 < mejorLongitud) {
            mejor = candidata;
            mejorLongitud = longitud;
            mejoro = true;
          }
        }
      }
    }
    return mejor;
  }

  static double _longitud(
    List<Pedido> ruta,
    ({double lat, double lng}) inicio,
  ) {
    var total = 0.0;
    var actual = inicio;
    for (final p in ruta) {
      final punto = (lat: p.lat, lng: p.lng);
      total += distanciaKm(actual, punto);
      actual = punto;
    }
    return total;
  }

  /// Distancia de Haversine en kilómetros.
  static double distanciaKm(
    ({double lat, double lng}) a,
    ({double lat, double lng}) b,
  ) {
    const radioTierra = 6371.0;
    double rad(double g) => g * math.pi / 180;
    final dLat = rad(b.lat - a.lat);
    final dLng = rad(b.lng - a.lng);
    final h =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(a.lat)) *
            math.cos(rad(b.lat)) *
            math.pow(math.sin(dLng / 2), 2);
    return 2 * radioTierra * math.asin(math.sqrt(h));
  }
}
