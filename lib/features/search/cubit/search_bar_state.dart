part of 'search_bar_cubit.dart';

enum SearchBarStatus { initial, loading, success, failure }

class SearchBarState extends Equatable {
  const SearchBarState({
    this.status = SearchBarStatus.initial,
    this.places = const {},
  });
  final SearchBarStatus status;
  final Set<Place> places;

  SearchBarState copyWith({SearchBarStatus? status, Set<Place>? places}) {
    return SearchBarState(
      status: status ?? this.status,
      places: places ?? this.places,
    );
  }

  @override
  List<Object> get props => [status, places];
}
