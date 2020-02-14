import '../enums/order.dart';

/// ItemsQuery
abstract class ItemsQuery {
  /// Show dropdown name instead of id. Default: false.
  bool expandDropdowns;

  /// Show relation of item in a links attribute. Default: true.
  bool getHateoas;

  /// Keep only id keys in returned data. Default: false.
  bool onlyId;

  /// Start of pagination. Default: 0.
  int startRange;

  /// End of pagination. Default: 50.
  int endRange;

  /// id of the searchoption to sort by. Default: 'id'.
  String sort;

  /// ASC - Ascending sort / DESC Descending sort. Default: ASC.
  Order order;

  /// Default Constructor
  ItemsQuery({
    this.expandDropdowns,
    this.getHateoas,
    this.onlyId,
    this.startRange,
    this.endRange,
    this.sort,
    this.order,
  });

  String get _range => (endRange < startRange)
      ? throw RangeError.value(endRange, 'endRange',
          'endRange must be greater than or equal to $startRange')
      : '$startRange-$endRange';

  /// Returns the Map with the values of the object.
  /// Note that some values cannot be null, or they can cause errors.
  Map<String, String> toMap() => <String, String>{
        'expand_dropdowns': expandDropdowns?.toString(),
        'get_hateoas': getHateoas?.toString(),
        'only_id': onlyId?.toString(),
        'range': _range,
        'sort': sort?.toString(),
        'order': order?.toStringValue()
      };
}

/// Creates a query to be used with [GlpiApi.getAllItems].
class AllItemsQuery extends ItemsQuery {
  /// Map of filters to pass on the query
  /// (<[String]:[Object]> field and value the text to search).
  Map<String, Object> searchText;

  /// Return deleted element. Default: false.
  bool isDeleted;

  /// Default constructor.
  AllItemsQuery(
      {bool expandDropdowns = false,
      bool getHateoas = true,
      bool onlyId = false,
      int startRange = 0,
      int endRange = 50,
      String sort = 'id',
      Order order = Order.asc,
      this.searchText,
      this.isDeleted = false})
      : super(
            expandDropdowns: expandDropdowns,
            getHateoas: getHateoas,
            onlyId: onlyId,
            startRange: startRange,
            endRange: endRange,
            sort: sort,
            order: order);

  /// Returns the Map with the values of the object.
  /// Note that some values cannot be null, or they can cause errors.
  @override
  Map<String, String> toMap() => super.toMap()
    ..['is_deleted'] = isDeleted.toString()
    ..addAll(_searchText);

  Map<String, String> get _searchText =>
      Map.fromIterable(searchText?.entries ?? {},
          key: (it) => 'searchText[${it.key}]',
          value: (it) => it?.value.toString());
}

/// /// Creates a query to be used with [GlpiApi.getSubItems]
class SubItemsQuery extends ItemsQuery {
  /// Default Constructor.
  SubItemsQuery(
      {bool expandDropdowns = false,
      bool getHateoas = true,
      bool onlyId = false,
      int startRange = 0,
      int endRange = 50,
      String sort = 'id',
      Order order = Order.asc})
      : super(
            expandDropdowns: expandDropdowns,
            getHateoas: getHateoas,
            onlyId: onlyId,
            startRange: startRange,
            endRange: endRange,
            sort: sort,
            order: order);
}
