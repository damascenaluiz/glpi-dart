import '../../glpi.dart';
import '../enums/item_type.dart';
import '../enums/link.dart';
import '../enums/search_type.dart';

/// Criteria object.
class Criteria {
  /// Logical operator.
  Link link;

  /// Id of the searchoption.
  int field;

  /// If true, it is a meta-criteria. You must provide an [ItemType] as well.
  bool meta;

  /// For metra = true, enter the ItemType.
  ItemType itemType;

  /// Type of search.
  SearchType searchType;

  /// The value to be searched.
  Object value;

  /// List of Criteria.
  Criteria criteria;

  /// Default Constructor.
  ///
  /// If you set meta = true, indicate the itemType.
  /// A Link is not required if it is the first object
  /// in the criteria list of a SearchCriteria object.
  Criteria(
    this.field,
    this.searchType,
    this.value, {
    this.link,
    this.meta,
    this.itemType,
    this.criteria
  });

  /// Returns a Map from a [Criteria],
  /// all values are converted to Strings
  /// and null values are discarded.
  Map<String, String> toMap() {
    {
      if ((meta == false) && (itemType is ItemType)) {
        throw ArgumentError.value(
            meta, 'meta can be true when a itemType is provided.');
      } else if ((meta == true) && !(itemType is ItemType)) {
        throw ArgumentError.value(
            itemType, 'A valid itemType should be provided when meta==true.');
      } else if ((meta == true) && !(link is Link)) {
        throw ArgumentError.value(
            link,
            'A valid Link must be provided when a '
            'criteria represents a metacriteria');
      } else {
        return {
          'link': link?.toStringValue(),
          'itemtype': itemType.toStringValue(),
          'searchtype': searchType?.toStringValue(),
          'value': value?.toString(),
          'field': field?.toString(),
          'meta': meta?.toString(),
          'criteria': [criteria?.toMap()].toString(),
        }..removeWhere((k, v) => v == null);
      }
    }
  }
}

/// To use with com [GlpiApi.searchItem].
class SearchCriteria {
  /// Id of the searchoption to sort by.
  int sort;

  /// Asceding or Descending sort.
  Order order;

  /// Start of search results.
  int startRange;

  /// End of search results.
  int endRange;

  /// List of columns to display.
  List<int> forceDisplay;

  /// Shows raw data.
  bool rawData;

  /// Boolean to retrieve rows indexed by items id.
  bool withIndexes;

  /// Identifies columns by 'uniqid'.
  bool uidCols;

  /// Indicates whether to receive html handled by the core. /// New data is sent in the data_html key.
  bool giveItems;

  /// List of [Criteria] objects.
  List<Criteria> criteria;

  /// Default Constructor.
  ///
  /// Creates a SearchCriteria to use with the method [GlpiApi.searchItem]
  SearchCriteria(
      {this.sort = 1,
      this.order = Order.asc,
      this.startRange = 0,
      this.endRange = 50,
      this.forceDisplay = const [],
      this.rawData = false,
      this.withIndexes = false,
      this.uidCols = false,
      this.giveItems = false,
      this.criteria = const []});

  /// Returns a Map from a [SearchCriteria],
  /// all values are converted to Strings
  /// and null values are discarded.
  Map<String, String> toMap() => {
        'sort': sort?.toString(),
        'order': order?.toStringValue(),
        'range': _range,
        'forcedisplay': forceDisplay?.toString(),
        'rawdata': rawData?.toString(),
        'withindexes': withIndexes?.toString(),
        'uid_cols': uidCols?.toString(),
        'giveItems': giveItems?.toString(),
      }
        ..removeWhere((k, v) => v == null)
        ..addAll(_criteriaMap);

  String get _range => (endRange < startRange)
      ? throw RangeError.value(endRange, 'endRange',
          'endRange must be greater than or equal to $startRange')
      : '$startRange-$endRange';

  Map<String, String> get _criteriaMap {
    final map = <String, String>{};
    if (criteria is List<Criteria>) {
      var index = 0;
      for (var crit in criteria) {
        if (index > 0 && !(crit.link is Link)) {
          throw ArgumentError.value(
              crit.link, 'Criteria in position $index, has not a valid Link');
        }
        map.addAll(
            crit.toMap().map((k, v) => MapEntry('criteria[$index][$k]', v)));
        index++;
      }
    }
    return map;
  }
}
