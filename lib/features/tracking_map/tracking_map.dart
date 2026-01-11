import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:peak_trail/features/tracking_map/widgets/actions_list.dart';
import 'package:peak_trail/features/tracking_map/widgets/metrics_grid.dart';

import 'widgets/animated_action_btn.dart';

class TrackingMapView extends StatefulWidget {
  const TrackingMapView({super.key});

  @override
  State<TrackingMapView> createState() => _TrackingMapViewState();
}

class _TrackingMapViewState extends State<TrackingMapView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height: MediaQuery.sizeOf(context).height * 0.08,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey)),
        ),
        padding: const EdgeInsets.all(8),
        child: AnimatedActionBtn(),
      ),
      body: Stack(
        children: [
          // 1. Map Layer
          const _MapLayer(),

          // 2. Bottom Sheet Layer
          const _BottomSheetLayer(),
        ],
      ),
    );
  }
}

class _MapLayer extends StatelessWidget {
  const _MapLayer();

  @override
  Widget build(BuildContext context) {
    // Basic MapWidget setup without credentials for preview structure
    // In a real app, ensure MapboxAccessToken is set in info.plist/AndroidManifest
    return mapbox.MapWidget(
      cameraOptions: mapbox.CameraOptions(
        center: mapbox.Point(
          coordinates: mapbox.Position(-70.6693, -33.4489),
        ), // Santiago, Chile
        zoom: 13.0,
      ),
    );
  }
}

class _BottomSheetLayer extends StatelessWidget {
  const _BottomSheetLayer();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.15,
        minChildSize: 0.15,
        maxChildSize: 1.0,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  // Handle indicator
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Metrics Grid
                  const MetricsGridWidget(),

                  // Action List
                  const ActionsListWidget(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
