sealed class SearchState {
  const SearchState();
}

final class SearchInitialState extends SearchState {
  const SearchInitialState();
}

final class SearchLoadingState extends SearchState {
  const SearchLoadingState();
}

final class SearchSuccessState extends SearchState {
  final String query;
  final String activeCategory;
  final List<Map<String, String>> results;

  const SearchSuccessState({
    required this.query,
    required this.activeCategory,
    required this.results,
  });
}
