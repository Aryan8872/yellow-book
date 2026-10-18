import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../config/map_config.dart';

/// Base MapLibre map widget with camera controls
class MapLibreMapWidget extends StatefulWidget {
  final MapLibreMapController? controller;
  final LatLng initialCenter;
  final double initialZoom;
  final double minZoom;
  final double maxZoom;
  final List<Symbol>? symbols;
  final List<Circle>? circles;
  final Function(LatLng)? onMapClick;
  final Function(LatLng)? onMapLongClick;
  final Function()? onStyleLoaded;
  final Widget? attributionWidget;

  const MapLibreMapWidget({
    super.key,
    this.controller,
    LatLng? initialCenter,
    double? initialZoom,
    double? minZoom,
    double? maxZoom,
    this.symbols,
    this.circles,
    this.onMapClick,
    this.onMapLongClick,
    this.onStyleLoaded,
    this.attributionWidget,
  })  : initialCenter = initialCenter ??
            const LatLng(MapConfig.defaultLatitude, MapConfig.defaultLongitude),
        initialZoom = initialZoom ?? MapConfig.defaultZoom,
        minZoom = minZoom ?? MapConfig.minZoom,
        maxZoom = maxZoom ?? MapConfig.maxZoom;

  @override
  State<MapLibreMapWidget> createState() => _MapLibreMapWidgetState();
}

class _MapLibreMapWidgetState extends State<MapLibreMapWidget> {
  MapLibreMapController? _mapController;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _mapController = widget.controller;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MapLibreMap(
          initialCameraPosition: CameraPosition(
            target: widget.initialCenter,
            zoom: widget.initialZoom,
          ),
          styleString: MapConfig.styleUrl,
          onMapCreated: _onMapCreated,
          onStyleLoadedCallback: widget.onStyleLoaded,
          minMaxZoomPreference: MinMaxZoomPreference(widget.minZoom, widget.maxZoom),
          onMapClick: widget.onMapClick != null
              ? (point, latLng) => widget.onMapClick!(latLng)
              : null,
          onMapLongClick: widget.onMapLongClick != null
              ? (point, latLng) => widget.onMapLongClick!(latLng)
              : null,
        ),
        // Attribution widget
        if (widget.attributionWidget != null)
          Positioned(
            left: 10,
            bottom: 10,
            child: widget.attributionWidget!,
          )
        else
          Positioned(
            left: 10,
            bottom: 10,
            child: _DefaultAttribution(),
          ),
      ],
    );
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
  }

  /// Move camera to specified location
  void moveCamera(LatLng target, double zoom) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(target, zoom),
    );
  }
}

/// Default attribution widget for map
class _DefaultAttribution extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        MapConfig.attribution,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.black87,
        ),
      ),
    );
  }
}
