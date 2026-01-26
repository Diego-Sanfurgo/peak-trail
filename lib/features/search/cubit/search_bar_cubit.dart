import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:peak_trail/data/models/peak.dart';
import 'package:peak_trail/data/repositories/peak_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'search_bar_state.dart';

class SearchBarCubit extends Cubit<SearchBarState> {
  SearchBarCubit(this._mountainsRepository) : super(SearchBarStatus()) {
    _init();
  }

  final PeakRepository _mountainsRepository;
  final List<Map<String, dynamic>> _jsonPeaks = [];

  Future<void> _init() async {
    // final String jsonData = await _mountainsRepository.getPeaksJson();
    // _jsonPeaks.addAll(
    //   jsonDecode(jsonData)['features'].cast<Map<String, dynamic>>(),
    // );
  }

  Future<void> queryPeaks(String query) async {
    try {
      if (query.isEmpty) {
        emit(SearchBarStatus());
        return;
      }

      emit(SearchBarStatus(isLoading: true));

      // Al seleccionar un item:
      // mapboxMap.flyTo(CameraOptions(center: Point(coordinates: Position(lng, lat)), zoom: 14));

      // List<Map> matches = _jsonPeaks.where((peak) {
      //   final String name = peak['properties']['name'];
      //   return _normalize(name).contains(_normalize(query));
      // }).toList();

      // final List<Peak> filteredMountains = matches.map((peakJson) {
      //   return Peak.fromJson(peakJson as Map<String, dynamic>);
      // }).toList();

      final response = await Supabase.instance.client
          .from('search_places_view')
          .select()
          .ilike('name', '%$query%') // Búsqueda parcial insensible a mayúsculas
          .limit(10); // Limita resultados para performance UI

      final List<Map<String, dynamic>> filteredMountains =
          List<Map<String, dynamic>>.from(response);

      log(filteredMountains.toString());

      // emit(SearchBarStatus(mountains: filteredMountains));
    } on Exception catch (e, stack) {
      log(e.toString(), stackTrace: stack);
    }
  }
}

String _normalize(String text) {
  var withDia =
      'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
  var withoutDia =
      'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeecCdDIIIIiiiiUUUUuuuuNnSsYyyZz';

  for (int i = 0; i < withDia.length; i++) {
    text = text.replaceAll(withDia[i], withoutDia[i]);
  }

  return text.toLowerCase().trim();
}
