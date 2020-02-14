/// Type of search. Use with [GlpiApi.searchItem].
///
/// All values: [contains],[equals],[notequals],
/// [lessthan],[morethan],[under],[notunder]
enum SearchType {
  /// [contains] will use a wildcard search per default.
  contains,

  /// [equals] is designed to be used with dropdowns
  equals,

  /// [notequals] are designed to be used with dropdowns
  notequals,

  ///[lessthan] value.
  lessthan,

  ///[morethan] value.
  morethan,

  ///[under] value.
  under,

  ///[notunder] value.
  notunder
}

///Extension to get String value of SearchType.
extension SearchTypeMethods on SearchType {
  ///Returns a String representation of the SearchType value.
  String toStringValue() {
    switch (this) {
      case SearchType.contains:
        return 'contains';
      case SearchType.equals:
        return 'equals';
      case SearchType.lessthan:
        return 'lessthan';
      case SearchType.morethan:
        return 'morethan';
      case SearchType.notequals:
        return 'notequals';
      case SearchType.notunder:
        return 'notunder';
      case SearchType.under:
        return 'under';
      default:
        return '';
    }
  }
}
