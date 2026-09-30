sealed class SearchEvent {
  const SearchEvent();
}

final class SearchQueryChanged extends SearchEvent {
  final String query;
  const SearchQueryChanged(this.query);
}

final class SearchCategoryFilterApplied extends SearchEvent {
  final String category;
  const SearchCategoryFilterApplied(this.category);
}

final class SearchCleared extends SearchEvent {
  const SearchCleared();
}
