/// Enum to [GlpiApi.AllItemsQuery]
enum Order {
  /// Ascending sort.
  asc,

  /// Descending sort.
  desc
}

///Extension to get String value of [Order].
extension OrderMethods on Order {
  ///Returns a String representation of the [Order] value.
  String toStringValue() {
    switch (this) {
      case Order.asc:
        return 'ASC';
      case Order.desc:
        return 'DESC';
      default:
        return '';
    }
  }
}
