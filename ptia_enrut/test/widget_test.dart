import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ptia_enrut/main.dart';
import 'package:ptia_enrut/models/pedido.dart';
import 'package:ptia_enrut/services/geocoder.dart';
import 'package:ptia_enrut/services/route_optimizer.dart';
import 'package:ptia_enrut/state/app_state.dart';

Pedido _pedido(String id, double lat, double lng, {bool rapida = false}) =>
    Pedido(
      id: id,
      direccion: id,
      nombre: id,
      rapida: rapida,
      lat: lat,
      lng: lng,
    );

void main() {
  group('BogotaGeocoder', () {
    test('las calles mayores quedan más al norte', () {
      final sur = BogotaGeocoder.ubicar('Calle 100 #15-20');
      final norte = BogotaGeocoder.ubicar('Calle 145 #15-20');
      expect(norte.lat, greaterThan(sur.lat));
    });

    test('carrera y calle equivalentes caen en el mismo punto', () {
      final a = BogotaGeocoder.ubicar('Carrera 104 #139-20');
      final b = BogotaGeocoder.ubicar('Calle 139 #104-20');
      expect(a.lat, closeTo(b.lat, 1e-9));
      expect(a.lng, closeTo(b.lng, 1e-9));
    });
  });

  group('RouteOptimizer', () {
    const inicio = (lat: 0.0, lng: 0.0);

    test('ordena paradas en línea sin ir y volver', () {
      final ruta = RouteOptimizer.optimizar([
        _pedido('c', 0.03, 0),
        _pedido('a', 0.01, 0),
        _pedido('b', 0.02, 0),
      ], inicio: inicio);
      expect(ruta.paradas.map((p) => p.id), ['a', 'b', 'c']);
    });

    test('los pedidos de rápida entrega van primero', () {
      final ruta = RouteOptimizer.optimizar([
        _pedido('cerca', 0.01, 0),
        _pedido('urgente', 0.05, 0, rapida: true),
      ], inicio: inicio);
      expect(ruta.paradas.first.id, 'urgente');
    });
  });

  testWidgets('flujo: login → paquetes de empresa → mapa', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    addTearDown(appState.cerrarSesion);

    await tester.pumpWidget(const EnrutApp());
    expect(find.text('Enrut.AI'), findsOneWidget);

    await tester.tap(find.text('Ingresar'));
    await tester.pump();
    expect(find.text('Ingresa tu correo electrónico'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'repa@enrut.ai');
    await tester.enterText(find.byType(TextFormField).at(1), 'secreto123');
    await tester.tap(find.text('Ingresar'));
    await tester.pumpAndSettle();
    expect(find.text('¿Cómo gestionarás tus entregas hoy?'), findsOneWidget);

    await tester.tap(find.textContaining('Paquetes asignados'));
    await tester.pumpAndSettle();
    expect(find.text('Lista de Entregas'), findsOneWidget);
    expect(appState.pedidos, hasLength(5));

    await tester.tap(find.text('Inicia tu ruta'));
    await tester.pumpAndSettle();
    expect(find.text('Mapa de Rutas'), findsOneWidget);
    expect(find.text('Pedidos que hacen falta:'), findsOneWidget);
    expect(appState.ruta.first.rapida, isTrue);
    expect(appState.ruta.first.estado, EstadoPedido.enCamino);
  });
}
