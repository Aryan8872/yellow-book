import 'dart:math' as math;

class OfferMapCluster {
  final double latitude;
  final double longitude;
  final List<Map<String, dynamic>> offers;

  const OfferMapCluster({
    required this.latitude,
    required this.longitude,
    required this.offers,
  });

  bool get isCluster => offers.length > 1;

  String? get categorySlug =>
      isCluster ? null : offers.single['categorySlug'] as String?;
}

class OfferMapClusterer {
  static const defaultRadiusPixels = 48.0;

  static List<OfferMapCluster> cluster(
    List<Map<String, dynamic>> pins, {
    required double zoom,
    double radiusPixels = defaultRadiusPixels,
  }) {
    final orderedPins = pins.where(_hasValidCoordinates).toList()
      ..sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));
    final worldSize = 512 * math.pow(2, zoom);
    final groups = <_PinGroup>[];

    for (final pin in orderedPins) {
      final point = _project(
        pin['lat'] as double,
        pin['lng'] as double,
        worldSize,
      );
      _PinGroup? matchingGroup;
      for (final group in groups) {
        if (_distancePixels(group.center, point, worldSize) <= radiusPixels) {
          matchingGroup = group;
          break;
        }
      }
      if (matchingGroup == null) {
        groups.add(_PinGroup(point, pin));
      } else {
        matchingGroup.add(point, pin);
      }
    }

    return groups.map((group) {
      final coordinate = _unproject(group.center, worldSize);
      return OfferMapCluster(
        latitude: coordinate.latitude,
        longitude: coordinate.longitude,
        offers: List.unmodifiable(group.pins),
      );
    }).toList();
  }

  static double zoomForCluster(double currentZoom) =>
      (currentZoom + 2).clamp(3.0, 18.0).toDouble();

  static bool _hasValidCoordinates(Map<String, dynamic> pin) {
    final latitude = pin['lat'];
    final longitude = pin['lng'];
    return latitude is double &&
        longitude is double &&
        latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  static _PixelPoint _project(
    double latitude,
    double longitude,
    num worldSize,
  ) {
    final clampedLatitude = latitude.clamp(-85.0511, 85.0511);
    final latitudeRadians = clampedLatitude * math.pi / 180;
    final x = (longitude + 180) / 360 * worldSize;
    final y =
        (1 -
            math.log(
                  math.tan(latitudeRadians) + 1 / math.cos(latitudeRadians),
                ) /
                math.pi) /
        2 *
        worldSize;
    return _PixelPoint(x.toDouble(), y.toDouble());
  }

  static _GeoPoint _unproject(_PixelPoint point, num worldSize) {
    final longitude = point.x / worldSize * 360 - 180;
    final mercator = math.pi * (1 - 2 * point.y / worldSize);
    final latitude =
        (2 * math.atan(math.exp(mercator)) - math.pi / 2) * 180 / math.pi;
    return _GeoPoint(latitude, longitude);
  }

  static double _distancePixels(
    _PixelPoint first,
    _PixelPoint second,
    num worldSize,
  ) {
    final rawXDistance = (first.x - second.x).abs();
    final xDistance = math.min(rawXDistance, worldSize - rawXDistance);
    final yDistance = first.y - second.y;
    return math.sqrt(xDistance * xDistance + yDistance * yDistance);
  }
}

class _PinGroup {
  final List<Map<String, dynamic>> pins;
  double _x;
  double _y;

  _PinGroup(_PixelPoint point, Map<String, dynamic> pin)
    : pins = [pin],
      _x = point.x,
      _y = point.y;

  _PixelPoint get center => _PixelPoint(_x, _y);

  void add(_PixelPoint point, Map<String, dynamic> pin) {
    final count = pins.length + 1;
    _x = (_x * pins.length + point.x) / count;
    _y = (_y * pins.length + point.y) / count;
    pins.add(pin);
  }
}

class _PixelPoint {
  final double x;
  final double y;

  const _PixelPoint(this.x, this.y);
}

class _GeoPoint {
  final double latitude;
  final double longitude;

  const _GeoPoint(this.latitude, this.longitude);
}
