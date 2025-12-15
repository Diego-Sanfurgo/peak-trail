import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:peak_trail/data/models/peak.dart';
import 'package:peak_trail/data/repositories/peaks_repository.dart';

part 'search_bar_state.dart';

class SearchBarCubit extends Cubit<SearchBarState> {
  SearchBarCubit(this._mountainsRepository) : super(SearchBarStatus()) {
    _init();
  }

  final PeaksRepository _mountainsRepository;
  final List<Map<String, dynamic>> _jsonPeaks = [];

  Future<void> _init() async {
    final String jsonData = await _mountainsRepository.getPeaksJson();
    _jsonPeaks.addAll(
      jsonDecode(jsonData)['features'].cast<Map<String, dynamic>>(),
    );
  }

  Future<void> queryPeaks(String query) async {
    try {
      if (query.isEmpty) {
        emit(SearchBarStatus());
        return;
      }

      emit(SearchBarStatus(isLoading: true));

      List<Map> matches = _jsonPeaks.where((peak) {
        final String name = peak['properties']['name'];
        return _normalize(name).contains(_normalize(query));
      }).toList();

      final List<Peak> filteredMountains = matches.map((peakJson) {
        return Peak.fromJson(peakJson as Map<String, dynamic>);
      }).toList();

      emit(SearchBarStatus(mountains: filteredMountains));
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
