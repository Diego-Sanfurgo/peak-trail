import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:peak_trail/data/models/mountain.dart';
import 'package:peak_trail/data/repositories/mountains_repository.dart';

part 'search_bar_state.dart';

class SearchBarCubit extends Cubit<SearchBarState> {
  SearchBarCubit() : super(SearchBarStatus()) {
    _init();
  }

  final MountainsRepository _mountainsRepository = MountainsRepository();
  final Set<Mountain> _allPeaks = {};

  Future<void> _init() async {
    _allPeaks.addAll(await _mountainsRepository.getPeaks());
  }

  Future<void> queryMountains(String query) async {
    if (query.isEmpty) {
      emit(SearchBarStatus());
      return;
    }

    emit(SearchBarStatus(isLoading: true));

    final List<Mountain> filteredMountains = _allPeaks.where((mountain) {
      final String name = mountain.properties.name;
      return name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    emit(SearchBarStatus(mountains: filteredMountains));
  }
}
