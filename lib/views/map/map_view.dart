import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../home/bloc/map_bloc.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MapViewWidget();
  }
}

class _MapViewWidget extends StatefulWidget {
  const _MapViewWidget();

  @override
  State<_MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<_MapViewWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: _Body()));
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _MapboxWidget(),
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            spacing: 8,
            children: [
              FloatingActionButton(
                heroTag: Key("tracking_FAB"),
                child: Icon(Icons.play_circle_outlined),
                onPressed: () =>
                    BlocProvider.of<MapBloc>(context).add(MapStartTracking()),
              ),
              FloatingActionButton(
                heroTag: Key("location_FAB"),
                child: Icon(Icons.my_location_rounded),
                onPressed: () =>
                    BlocProvider.of<MapBloc>(context).add(MapCameraToMe()),
              ),
            ],
          ),
        ),

        Positioned(
          top: 84,
          right: 16,
          child: FloatingActionButton.small(
            heroTag: Key("layer_FAB"),
            child: Icon(Icons.layers_rounded),
            onPressed: () {},
          ),
        ),

        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
            ),
            child: TextFormField(
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MapboxWidget extends StatefulWidget {
  const _MapboxWidget();

  @override
  State<_MapboxWidget> createState() => _MapboxWidgetState();
}

class _MapboxWidgetState extends State<_MapboxWidget>
    with AutomaticKeepAliveClientMixin {
  MapboxMap? mapController;
  late final MapBloc bloc;
  // Timer? idleTimer;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<MapBloc>(context);
  }

  @override
  void dispose() {
    // mapController?.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        state as MapStatus;

        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return MapWidget(
          // key: ValueKey("map_widget"),
          key: const PageStorageKey('pathfinder-map'),
          onMapCreated: (controller) {
            mapController = controller;
            controller.attribution.updateSettings(
              AttributionSettings(marginBottom: 24, marginLeft: 88),
            );
            controller.compass.updateSettings(
              CompassSettings(marginTop: 140, marginRight: 16),
            );
            controller.logo.updateSettings(LogoSettings(marginBottom: 24));
            controller.scaleBar.updateSettings(
              ScaleBarSettings(
                position: OrnamentPosition.BOTTOM_LEFT,
                // marginTop: MediaQuery.of(context).size.height * 0.08,
              ),
            );
            bloc.add(MapCreated(controller));
          },
          styleUri: MapboxStyles.OUTDOORS,
          mapOptions: MapOptions(pixelRatio: 2),
          cameraOptions: CameraOptions(zoom: 5),
          // onScrollListener: (mapContext) async {
          //   log(mapContext.gestureState.name);
          //   if (mapContext.gestureState.index != GestureState.ended.index) {
          //     return;
          //   }
          //   CameraState? cameraState = await mapController?.getCameraState();
          //   if (cameraState == null) return;
          //   bloc.add(MapCameraChanged(cameraState));
          // },
          // onMapIdleListener: (mapIdleEventData) {
          //   log("MAP IDLE");
          // },
          // onCameraChangeListener: (cameraChangedEventData) {
          //   if (mapController == null) return;
          //   // idleTimer?.cancel();
          //   // idleTimer = Timer(const Duration(milliseconds: 600), () async {
          //   //   // await _onCameraIdle();
          //   //   bloc.add(MapCameraChanged(cameraChangedEventData.cameraState));
          //   // });
          //   bloc.add(MapCameraChanged(cameraChangedEventData.cameraState));
          // },
        );
      },
    );
  }
}
