/// Geocodificador aproximado para la nomenclatura en malla de Bogotá.
///
/// En Bogotá las calles crecen hacia el norte y las carreras hacia el
/// occidente, así que "Calle 145 # 90-12" se puede ubicar aproximadamente
/// sin servicios externos. Es suficiente para ordenar paradas en el
/// prototipo; en producción se reemplaza por datos abiertos de la malla vial
/// o un servicio de geocodificación real.
class BogotaGeocoder {
  // Puntos de referencia: Calle 26 ≈ 4.620 lat, Carrera 7 ≈ -74.030 lng.
  static const _latCalle26 = 4.620;
  static const _latPorCalle = 0.0009;
  static const _lngCarrera7 = -74.030;
  static const _lngPorCarrera = 0.00055;

  /// Centro aproximado de la localidad de Suba (punto de partida por defecto).
  static const subaCentro = (lat: 4.7400, lng: -74.0830);

  static final _regex = RegExp(
    r'^\s*(avenida calle|avenida carrera|calle|carrera|diagonal|transversal'
    r'|cll|cl|cra|kra|kr|cr|dg|tv|ac|ak)\.?\s*(\d+)\s*[a-z]?\s*(?:bis)?\s*'
    r'(?:#|no\.?|n°)?\s*(\d+)',
    caseSensitive: false,
  );

  static const _tiposCalle = {
    'avenida calle', 'calle', 'diagonal', 'cll', 'cl', 'dg', 'ac', //
  };

  static ({double lat, double lng}) ubicar(String direccion) {
    final match = _regex.firstMatch(direccion.toLowerCase());
    if (match == null) return _respaldo(direccion);

    final tipo = match.group(1)!;
    final principal = int.parse(match.group(2)!);
    final cruce = int.parse(match.group(3)!);

    final esCalle = _tiposCalle.contains(tipo);
    final calle = esCalle ? principal : cruce;
    final carrera = esCalle ? cruce : principal;

    return (
      lat: _latCalle26 + (calle - 26) * _latPorCalle,
      lng: _lngCarrera7 - (carrera - 7) * _lngPorCarrera,
    );
  }

  /// Si la dirección no sigue la nomenclatura, se ubica de forma
  /// determinista dentro de Suba para que la ruta siga siendo estable.
  static ({double lat, double lng}) _respaldo(String direccion) {
    var hash = 0;
    for (final c in direccion.codeUnits) {
      hash = (hash * 31 + c) & 0x7fffffff;
    }
    final dx = (hash % 1000) / 1000 - 0.5;
    final dy = ((hash ~/ 1000) % 1000) / 1000 - 0.5;
    return (lat: subaCentro.lat + dy * 0.03, lng: subaCentro.lng + dx * 0.03);
  }
}
