import 'package:flutter/foundation.dart';

import '../models/pedido.dart';
import '../services/geocoder.dart';
import '../services/route_optimizer.dart';

/// Estado global de la app. Aún no hay backend: la sesión y los pedidos
/// viven en memoria mientras la app está abierta.
class AppState extends ChangeNotifier {
  String? email;
  String? codigoEmpresa;

  /// Pedidos en la "Lista de Entregas".
  final List<Pedido> pedidos = [];

  /// Ids de los pedidos que el repartidor marcó para entregar.
  final Set<String> seleccionados = {};

  /// Ruta activa (ordenada por el optimizador) y su distancia estimada.
  List<Pedido> ruta = [];
  double distanciaRutaKm = 0;

  final List<Pedido> entregados = [];

  int _siguienteId = 0;

  bool get sesionIniciada => email != null;

  void iniciarSesion(String email) {
    this.email = email.trim();
    notifyListeners();
  }

  void registrar({required String email, required String codigoEmpresa}) {
    this.email = email.trim();
    this.codigoEmpresa = codigoEmpresa.trim();
    notifyListeners();
  }

  void cerrarSesion() {
    email = null;
    codigoEmpresa = null;
    pedidos.clear();
    seleccionados.clear();
    ruta = [];
    distanciaRutaKm = 0;
    entregados.clear();
    notifyListeners();
  }

  Pedido agregarPedido({
    required String direccion,
    required String nombre,
    required bool rapida,
    EstadoPedido estado = EstadoPedido.pendiente,
    bool asignadoPorEmpresa = false,
  }) {
    final punto = BogotaGeocoder.ubicar(direccion);
    final pedido = Pedido(
      id: 'p${_siguienteId++}',
      direccion: direccion.trim(),
      nombre: nombre.trim(),
      rapida: rapida,
      lat: punto.lat,
      lng: punto.lng,
      estado: estado,
      asignadoPorEmpresa: asignadoPorEmpresa,
    );
    pedidos.add(pedido);
    seleccionados.add(pedido.id);
    notifyListeners();
    return pedido;
  }

  void eliminarPedido(Pedido pedido) {
    pedidos.remove(pedido);
    seleccionados.remove(pedido.id);
    notifyListeners();
  }

  void alternarSeleccion(Pedido pedido) {
    if (!seleccionados.remove(pedido.id)) seleccionados.add(pedido.id);
    notifyListeners();
  }

  /// Simula los paquetes que la empresa le asigna al repartidor.
  /// Se reemplaza por una consulta al backend usando [codigoEmpresa].
  void cargarPedidosEmpresa() {
    final yaCargados = pedidos.any((p) => p.asignadoPorEmpresa);
    if (yaCargados) return;
    const asignados = [
      ('Carrera 103A #141-45', 'Vanessa Torres', true, EstadoPedido.pendiente),
      ('Carrera 111 #152-43', 'Kenny Palcios', false, EstadoPedido.pendiente),
      ('Carrera 104 #139-20', 'Laura Gómez', false, EstadoPedido.pendiente),
      ('Calle 145 #90-15', 'Andrés Rojas', true, EstadoPedido.porDespachar),
      ('Calle 128 #95-40', 'Camila Pérez', false, EstadoPedido.porDespachar),
    ];
    for (final (direccion, nombre, rapida, estado) in asignados) {
      agregarPedido(
        direccion: direccion,
        nombre: nombre,
        rapida: rapida,
        estado: estado,
        asignadoPorEmpresa: true,
      );
    }
  }

  /// Optimiza los pedidos seleccionados y los convierte en la ruta activa.
  /// Devuelve false si no hay pedidos seleccionados.
  bool iniciarRuta() {
    final elegidos = pedidos
        .where((p) => seleccionados.contains(p.id))
        .toList();
    if (elegidos.isEmpty) return false;

    final resultado = RouteOptimizer.optimizar(
      elegidos,
      inicio: BogotaGeocoder.subaCentro,
    );
    ruta = resultado.paradas;
    distanciaRutaKm = resultado.distanciaKm;
    _actualizarEstadosRuta();
    notifyListeners();
    return true;
  }

  void marcarEntregado(Pedido pedido) {
    pedido
      ..estado = EstadoPedido.entregado
      ..entregadoEn = DateTime.now();
    ruta.remove(pedido);
    pedidos.remove(pedido);
    seleccionados.remove(pedido.id);
    entregados.insert(0, pedido);
    _actualizarEstadosRuta();
    notifyListeners();
  }

  /// La primera parada de la ruta siempre queda "En camino".
  void _actualizarEstadosRuta() {
    for (final (i, p) in ruta.indexed) {
      if (i == 0) {
        p.estado = EstadoPedido.enCamino;
      } else if (p.estado == EstadoPedido.enCamino) {
        p.estado = EstadoPedido.pendiente;
      }
    }
  }
}

final appState = AppState();
