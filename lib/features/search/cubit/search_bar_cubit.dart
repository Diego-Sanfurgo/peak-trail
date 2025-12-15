import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:peak_trail/data/models/peak.dart';
import 'package:peak_trail/data/repositories/peaks_repository.dart';

part 'search_bar_state.dart';

class SearchBarCubit extends Cubit<SearchBarState> {
  SearchBarCubit() : super(SearchBarStatus()) {
    _init();
  }

  final PeaksRepository _mountainsRepository = PeaksRepository();
  final Set<Peak> _allPeaks = {};

  Future<void> _init() async {
    _allPeaks.addAll(await _mountainsRepository.getPeaks());
  }

  Future<void> queryMountains(String query) async {
    if (query.isEmpty) {
      emit(SearchBarStatus());
      return;
    }

    emit(SearchBarStatus(isLoading: true));

    final List<Peak> filteredMountains = _allPeaks.where((mountain) {
      final String name = mountain.properties.name;
      return name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    emit(SearchBarStatus(mountains: filteredMountains));
  }
}
