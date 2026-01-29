import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:latlong2/latlong.dart';

import 'package:peak_trail/core/services/navigation_service.dart';
import 'package:peak_trail/data/models/place.dart';

import 'package:peak_trail/data/providers/place_provider.dart';
import 'package:peak_trail/data/repositories/place_repository.dart';
import 'package:peak_trail/features/home/bloc/map_bloc.dart';
import 'package:peak_trail/widgets/animated_search_text.dart';

import 'cubit/search_bar_cubit.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => PlaceRepository(PlaceProvider()),
      child: BlocProvider(
        create: (context) => SearchBarCubit(context.read<PlaceRepository>()),
        child: _SearchViewWidget(),
      ),
    );
  }
}

class _SearchViewWidget extends StatefulWidget {
  const _SearchViewWidget();

  @override
  State<_SearchViewWidget> createState() => _SearchViewWidgetState();
}

class _SearchViewWidgetState extends State<_SearchViewWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: _Body()));
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverAppBar(
            leading: BackButton(onPressed: () => NavigationService.pop()),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.filter_alt_outlined),
              ),
            ],
            titleSpacing: 0,
            title: _SearchBarWidget(),
            pinned: true,
            // floating: true,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.green),
              borderRadius: BorderRadiusGeometry.circular(30),
            ),
          ),
        ),

        BlocBuilder<SearchBarCubit, SearchBarState>(
          builder: (context, state) {
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.builder(
                itemCount: state.places.length,
                itemBuilder: (context, index) {
                  Place place = state.places.elementAt(index);
                  final String? subtitle =
                      place.districtName != null && place.stateName != null
                      ? '${place.districtName}, ${place.stateName}'
                      : place.districtName ?? place.stateName;

                  final IconData icon = switch (place.type) {
                    PlaceType.peak => Icons.volcano_outlined,
                    PlaceType.lake => Icons.water_outlined,
                    PlaceType.pass => Icons.terrain_outlined,
                    PlaceType.waterfall => Icons.water_drop_outlined,
                  };

                  return ListTile(
                    title: Text(place.name),
                    subtitle: subtitle != null
                        ? Text(
                            subtitle,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )
                        : null,
                    leading: Icon(icon),
                    trailing: Icon(Icons.arrow_right),
                    tileColor: Colors.white,
                    onTap: () {
                      NavigationService.pop();
                      BlocProvider.of<MapBloc>(context).add(
                        MapMoveCamera(
                          targetLocation: LatLng(
                            place.geom.coordinates.latitude,
                            place.geom.coordinates.longitude,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SearchBarWidget extends StatefulWidget {
  const _SearchBarWidget();

  @override
  State<_SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<_SearchBarWidget> {
  late final TextEditingController _controller;
  late final SearchBarCubit _cubit;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _cubit = BlocProvider.of<SearchBarCubit>(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: TextFormField(
        autofocus: true,
        decoration: InputDecoration(
          hint: AnimatedSearchText(),
          border: InputBorder.none,
        ),
        controller: _controller,
        onChanged: (value) => _cubit.queryPeaks(value),
        // elevation: WidgetStateProperty.all(0),
      ),
    );
  }
}
