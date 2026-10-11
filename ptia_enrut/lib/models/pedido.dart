enum EstadoPedido { porDespachar, pendiente, enCamino, entregado }

extension EstadoPedidoLabel on EstadoPedido {
  String get label => switch (this) {
    EstadoPedido.porDespachar => 'Por despachar',
    EstadoPedido.pendiente => 'Pendiente',
    EstadoPedido.enCamino => 'En camino',
    EstadoPedido.entregado => 'Entregado',
  };
}

class Pedido {
  Pedido({
    required this.id,
    required this.direccion,
    required this.nombre,
    required this.rapida,
    required this.lat,
    required this.lng,
    this.estado = EstadoPedido.pendiente,
    this.asignadoPorEmpresa = false,
  });

  final String id;
  final String direccion;
  final String nombre;

  /// "Rápida entrega": el optimizador lo prioriza al inicio de la ruta.
  final bool rapida;

  final double lat;
  final double lng;
  EstadoPedido estado;
  final bool asignadoPorEmpresa;
  DateTime? entregadoEn;
}
