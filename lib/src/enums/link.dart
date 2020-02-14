/// Enum to [GlpiApi.searchItem]
enum Link {
  /// AND operator.
  and,

  /// OR operator.
  or,

  /// AND+NOT operator.
  andNot,

  /// OR+NOT operator.
  orNot,
}

///Extension to get String value of Link.
extension LinkMethods on Link {
  ///Returns a String representation of the Link value.
  String toStringValue() {
    switch (this) {
      case Link.and:
        return 'AND';
      case Link.andNot:
        return 'AND NOT';
      case Link.or:
        return 'OR';
      case Link.orNot:
        return 'OR NOT';
      default:
        return '';
    }
  }
}
