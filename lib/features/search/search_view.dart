import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:peak_trail/core/services/navigation_service.dart';
import 'package:peak_trail/data/models/mountain.dart';
import 'package:peak_trail/features/home/bloc/map_bloc.dart';

import 'cubit/search_bar_cubit.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBarCubit(),
      child: _SearchBarWidget(),
    );
  }
}

class _SearchBarWidget extends StatefulWidget {
  const _SearchBarWidget();

  @override
  State<_SearchBarWidget> createState() => __SearchBarWidgetState();
}

class __SearchBarWidgetState extends State<_SearchBarWidget> {
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchBar(
                leading: BackButton(onPressed: () => NavigationService.pop()),
                autoFocus: true,
                controller: _controller,
                onChanged: (value) {
                  value.trim();
                  _cubit.queryMountains(value);
                },
              ),
            ),
            BlocBuilder<SearchBarCubit, SearchBarState>(
              builder: (context, state) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: state.mountains.length,
                    itemBuilder: (context, index) {
                      Mountain mountain = state.mountains[index];
                      return ListTile(
                        title: Text(mountain.properties.name),
                        subtitle: Text(
                          state.mountains
                              .elementAt(index)
                              .coordinates
                              .toString(),
                        ),
                        onTap: () {
                          NavigationService.pop();
                          BlocProvider.of<MapBloc>(context).add(
                            MapMoveCamera(
                              targetLocation: LatLng(
                                mountain.coordinates.lat,
                                mountain.coordinates.lng,
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
            // Additional UI elements can be added here
          ],
        ),
      ),
    );
  }
}
