import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:peak_trail/data/models/place.dart';
import 'package:peak_trail/data/repositories/place_repository.dart';

part 'search_bar_state.dart';

class SearchBarCubit extends Cubit<SearchBarState> {
  SearchBarCubit(this._placeRepository) : super(SearchBarStatus()) {
    _init();
  }

  final PlaceRepository _placeRepository;

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

      final String normalizedQuery = _normalize(query);

      final Set<Place> places = await _placeRepository.queryByName(
        normalizedQuery,
        isLimited: false,
      );

      emit(SearchBarStatus(places: places));
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
