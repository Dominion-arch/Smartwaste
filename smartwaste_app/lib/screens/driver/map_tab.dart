import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../config.dart';
import '../../models/models.dart';
import '../../state/driver_state.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

/// Real OpenStreetMap view of the driver's stops (replaces the web app's canvas sketch).
class MapTab extends StatelessWidget {
  final List<Bin> stops;
  const MapTab({super.key, required this.stops});

  @override
  Widget build(BuildContext context) {
    final driver = context.watch<DriverState>();
    final located = stops.where((b) => b.hasLocation).toList();

    if (located.isEmpty) {
      return const EmptyState('🗺️', 'None of your stops have GPS coordinates yet.\nAdd lat/lng to each sensor in the admin dashboard.');
    }

    final points = located.map((b) => LatLng(b.lat, b.lng)).toList();
    final center = LatLng(
      points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length,
      points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: points.isEmpty ? AppConfig.defaultCenter : center,
            initialZoom: 14,
            initialCameraFit: points.length > 1
                ? CameraFit.coordinates(coordinates: points, padding: const EdgeInsets.all(48), maxZoom: 17)
                : null,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.smartwaste.app',
            ),
            if (points.length > 1)
              PolylineLayer(polylines: [
                Polyline(points: points, strokeWidth: 3, color: C.info.withValues(alpha: 0.55)),
              ]),
            MarkerLayer(
              markers: [
                for (final b in located)
                  Marker(
                    point: LatLng(b.lat, b.lng),
                    width: 34,
                    height: 34,
                    child: _pin(b, stops.indexOf(b) + 1, driver.isDone(b.id)),
                  ),
              ],
            ),
            const RichAttributionWidget(
              attributions: [TextSourceAttribution('© OpenStreetMap contributors')],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pin(Bin b, int n, bool done) {
    final col = done ? const Color(0xFF2A3040) : C.fill(b.fill);
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: col,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
      ),
      child: Text(done ? '✓' : '$n',
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
    );
  }
}
