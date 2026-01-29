part of 'search_bar_cubit.dart';

sealed class SearchBarState extends Equatable {
  const SearchBarState({this.isLoading = false, this.places = const {}});
  final bool isLoading;
  final Set<Place> places;

  @override
  List<Object> get props => [isLoading, places];
}

class SearchBarStatus extends SearchBarState {
  const SearchBarStatus({super.isLoading, super.places});
}
