part of 'search_bar_cubit.dart';

sealed class SearchBarState extends Equatable {
  const SearchBarState({this.isLoading = false, this.mountains = const []});
  final bool isLoading;
  final List<Mountain> mountains;

  @override
  List<Object> get props => [isLoading, mountains];
}

class SearchBarStatus extends SearchBarState {
  const SearchBarStatus({super.isLoading, super.mountains});
}
