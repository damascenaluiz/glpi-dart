library glpi_api;

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p
    show normalize, basename, basenameWithoutExtension;
import 'package:http_parser/http_parser.dart' show MediaType;

import 'enums/item_type.dart';
import 'enums/request_method.dart';
import 'glpi_endpoint.dart';
import 'glpi_error.dart';
import 'query/item_criteria.dart';
import 'query/item_options.dart';
import 'query/items_query.dart';
import 'util.dart';

/// All REST API methods are available from this class.
///
/// Some methods will require the session-token to be first.
class GlpiApi {
  /// Glpi Server
  final GlpiEndpoint _glpiEndpoint;

  /// GLPI HTTP Client
  final http.BaseClient _client;

  String _sessionToken;

  /// Provided by authentication methods:
  /// [GlpiApi.initSessionByCredentials] or [GlpiApi.initSessionByUserToken].
  String get sessionToken => _sessionToken;

  /// Constructor
  GlpiApi(this._glpiEndpoint, {http.BaseClient client})
      : _client = client ??= http.Client();

  /// Logon with user and password.
  /// Request a session token to uses other methods.
  Future<void> initSessionByCredentials(String user, String password) async {
    ArgumentError.checkNotNull(user, 'user');
    ArgumentError.checkNotNull(password, 'password');
    final logon = encodeBase64('$user:$password');
    final headers = <String, String>{'Authorization': 'Basic $logon'};
    _sessionToken = (await _endpointRequest('initSession',
        headers: headers, enableSessionToken: false) as Map)['session_token'];
  }

  /// Logon with user's token. Request a session token to uses other methods.
  Future<void> initSessionByUserToken(String token) async {
    ArgumentError.checkNotNull(token, 'token');
    final headers = <String, String>{'Authorization': 'user_token $token'};
    _sessionToken = (await _endpointRequest('initSession',
        headers: headers, enableSessionToken: false) as Map)['session_token'];
  }

  /// Destroy a session identified by a session token.
  /// Ends the connection and clean resources.
  Future<void> killSession() async {
    await _endpointRequest('killSession');
    _sessionToken = null;
    _client.close();
  }

  /// Sends a notification to the user to reset his password.
  Future<List<dynamic>> recoveryPassword(String email) async {
    ArgumentError.checkNotNull(email, 'email');
    final body = <String, String>{'email': email};
    return await _endpointRequest('lostPassword',
        method: RequestMethod.put, body: body, enableSessionToken: false);
  }

  /// Reset a password from user.
  Future<void> resetPassword(
      String email, String passwordToken, String newPassword) async {
    ArgumentError.checkNotNull(email, 'email');
    ArgumentError.checkNotNull(passwordToken, 'passwordToken');
    ArgumentError.checkNotNull(newPassword, 'newPassword');
    final body = <String, String>{}
      ..['email'] = email
      ..['password_forget_token'] = passwordToken
      ..['password'] = newPassword;
    await _endpointRequest('lostPassword',
        method: RequestMethod.put, body: body, enableSessionToken: false);
  }

  /// Return all the profiles associated to logged user.
  Future<List<dynamic>> getMyProfiles() async {
    return (await _endpointRequest('getMyProfiles') as Map)['myprofiles'];
  }

  /// Return the current active profile.
  Future<Map<String, dynamic>> getActiveProfile() async {
    return (await _endpointRequest('getActiveProfile')
        as Map)['active_profile'];
  }

  /// Change active profile to the [profilesId] one.
  /// See [getMyProfiles] for possible profiles.
  Future<void> changeActiveProfile(int profilesId) async {
    ArgumentError.checkNotNull(profilesId, 'profilesId');
    final body = <String, int>{'profiles_id': profilesId};
    await _endpointRequest('changeActiveProfile',
        method: RequestMethod.post, body: body);
  }

  /// Return all the possible entities of the current logged user
  /// (and for current active profile).
  Future<List<dynamic>> getMyEntities({bool isRecursive = false}) async {
    final queryParameters = <String, String>{
      'is_recursive': isRecursive?.toString()
    };
    return (await _endpointRequest('getMyEntities',
        queryParameters: queryParameters) as Map)['myentities'];
  }

  /// Return active entities of current logged user.
  Future<Map<String, dynamic>> getActiveEntities() async {
    return (await _endpointRequest('getActiveEntities')
        as Map)['active_entity'];
  }

  /// Change active entity to the entitiesId one.
  /// See [getMyEntities] for possible entities.
  Future<bool> changeActiveEntities(
      {int entitiesId, bool isRecursive = false}) async {
    final body = <String, dynamic>{
      'entities_id': entitiesId ?? 'all',
      'is_recursive': isRecursive
    };
    return await _endpointRequest('changeActiveEntities',
        method: RequestMethod.post, body: body);
  }

  /// Return the current php $_SESSION.
  Future<Map<String, dynamic>> getFullSession() async {
    return (await _endpointRequest('getFullSession') as Map)['session'];
  }

  /// Return the current $CFG_GLPI.
  Future<Map<String, dynamic>> getGlpiConfig() async {
    return (await _endpointRequest('getGlpiConfig') as Map)['cfg_glpi'];
  }

  /// Return a List of rows of the [itemType].
  Future<List<dynamic>> getAllItems(ItemType itemType,
      [AllItemsQuery query]) async {
    ArgumentError.checkNotNull(itemType, 'itemType');
    return await _endpointRequest(enumToString(itemType),
        queryParameters: query?.toMap());
  }

  /// Return a list of the [subItemType] for the identified item.
  Future<List<dynamic>> getSubItems(
      ItemType itemType, int id, ItemType subItemType,
      [SubItemsQuery query]) async {
    ArgumentError.checkNotNull(itemType, 'itemType');
    ArgumentError.checkNotNull(id, 'id');
    ArgumentError.checkNotNull(subItemType, 'subItemType');
    return await _endpointRequest(
        [enumToString(itemType), id.toString(), enumToString(subItemType)],
        queryParameters: query?.toMap());
  }

  /// Return the instance fields of itemtype identified by id.
  Future<dynamic> getItem(ItemType itemType, int id,
      [ItemOptions options]) async {
    ArgumentError.checkNotNull(itemType, 'itemType');
    ArgumentError.checkNotNull(id, 'id');
    return await _endpointRequest([enumToString(itemType), id.toString()],
        queryParameters: options?.toMap());
  }

  /// Return multiples instance fields of itemtype identified by id.
  Future<dynamic> getMultipleItems(Map<ItemType, List<int>> items,
      [ItemOptions options]) async {
    ArgumentError.checkNotNull(items, 'items');
    var index = 0;
    var input = <String, String>{};
    for (MapEntry item in items.entries) {
      for (var id in item.value) {
        var itemType = enumToString(item.key);
        input['items[$index][itemtype]'] = itemType;
        input['items[$index][items_id]'] = id.toString();
        index++;
      }
    }
    input.addAll(options?.toMap() ?? {});
    return await _endpointRequest('getMultipleItems', queryParameters: input);
  }

  /// List the searchoptions of provided itemtype.
  /// To use with [GlpiApi.searchItems].
  ///
  /// The optional parameter return searchoption
  /// uncleaned (as provided by core).
  Future<Map<String, dynamic>> listSearchOptions(ItemType itemType,
      {bool raw}) async {
    ArgumentError.checkNotNull(itemType, 'itemType');
    final queryParameters = <String, String>{'raw': raw?.toString()};
    return await _endpointRequest(['listSearchOptions', enumToString(itemType)],
        queryParameters: queryParameters);
  }

  /// Expose the GLPI searchEngine and combine criteria
  /// to retrieve a list of elements of specified itemtype.
  ///
  /// Note: you can use [ItemType.AllAsset] to retrieve a combination
  /// of all asset's types.
  Future<dynamic> searchItems(ItemType itemType,
      [SearchCriteria search]) async {
    return await _endpointRequest(['search', enumToString(itemType)],
        queryParameters: search?.toMap() ?? {});
  }

  /// Add an object (or multiple objects) into GLPI.
  Future<dynamic> addItems(ItemType itemType, dynamic items) async {
    ArgumentError.checkNotNull(itemType, 'itemType');
    //check if items have expected type
    if (itemType == ItemType.Document && !(items is String)) {
      throw ArgumentError.value(
          items, 'item', 'must be a String to $itemType ');
    } else if (!(itemType == ItemType.Document) &&
        !(items is List<Map<String, dynamic>>) &&
        !(items is Map<String, dynamic>)) {
      //caught an error
      throw ArgumentError.value(items, "items",
          'must be List<Map<String,dynamic>> or Map<String,dynamic>');
    }
    final headers = <String, String>{};
    var body, method;
    if (itemType == ItemType.Document) {
      method = RequestMethod.file_upload;
      body = items;
    } else {
      method = RequestMethod.post;
      body = <String, dynamic>{}..['input'] = items;
    }
    return await _endpointRequest(enumToString(itemType),
        headers: headers, method: method, body: body);
  }

  /// Update an object (or multiple objects) existing in GLPI.
  Future<List<dynamic>> updateItems(ItemType itemType, dynamic items,
      [int id]) async {
    ArgumentError.checkNotNull(itemType, 'itemType');
    //check if items have expected type
    if (!(items is List<Map<String, dynamic>>) &&
        !(items is Map<String, dynamic>)) {
      //caught an exception
      throw ArgumentError.value(items, 'items',
          'must de List<Map<String,dynamic>> or Map<String,dynamic>');
    }
    //convert items to json notation
    final body = <String, dynamic>{'input': items},
        paths = <String>[enumToString(itemType)];
    if (id is int) {
      paths.add(id.toString());
    }
    return await _endpointRequest(paths, method: RequestMethod.put, body: body);
  }

  /// Delete an object existing in GLPI.
  Future<List<dynamic>> deleteItems(ItemType itemType,
      {int id,
      List<int> inputValues,
      bool forcePurge = false,
      bool history = true}) async {
    ArgumentError.checkNotNull(itemType);
    final paths = <String>[],
        body = <String, dynamic>{},
        queryParameters = <String, String>{};
    if (id is int) {
      //id parameter has precedence over input payload.
      paths.add(id.toString());
      queryParameters['force_purge'] = forcePurge.toString();
      queryParameters['history'] = history.toString();
    } else {
      if (inputValues is List<int> && inputValues.isNotEmpty) {
        final input = toJsonIds(inputValues);
        body['input'] = input;
        body['force_purge'] = forcePurge;
        body['history'] = history;
      } else {
        throw ArgumentError("You must specify at least one of two parameters:"
            " 'id' or 'inputValues'");
      }
    }
    paths.insert(0, enumToString(itemType));
    return await _endpointRequest(paths,
        queryParameters: queryParameters,
        body: body,
        method: RequestMethod.delete);
  }

  /// Download a document.
  Future<http.Response> download(int id, {bool useAlt = false}) async {
    ArgumentError.checkNotNull(id);
    ArgumentError.checkNotNull(useAlt);
    final headers = <String, String>{},
        queryParameters = <String, String>{},
        paths = ['Document', id.toString()];
    if (useAlt == false) {
      headers['Accept'] = 'application/octet-stream';
    } else {
      queryParameters['alt'] = 'media';
    }
    return await _endpointRequest(
      paths,
      method: RequestMethod.file_download,
      headers: headers,
      queryParameters: queryParameters,
    );
  }

  dynamic _endpointRequest(Object paths,
      {Map<String, String> queryParameters,
      Map<String, String> headers,
      RequestMethod method = RequestMethod.get,
      Object body,
      bool enableSessionToken = true}) async {
    queryParameters ??= {};
    headers ??= {};
    //Request part
    var request = _makeRequest(method, paths, queryParameters);
    _addHeaders(headers, enableSessionToken, request);

    if (request is http.MultipartRequest) {
      _addFile(body, request);
    } else {
      _addBody(body, request);
    }
    //Response part
    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    print(request.url);
    if (GlpiError.errors.contains(response.statusCode)) {
      _throwGlpiError(response.body);
    }
    if (method == RequestMethod.file_download) {
      return response;
    } else {
      print(response.body);
      return fromJson(response.body);
    }
  }

//Creates a request based on the method.
  http.BaseRequest _makeRequest(
      RequestMethod method, Object paths, Map<String, String> queryParameters) {
    //Request part.
    http.BaseRequest request;
    switch (method) {
      case RequestMethod.file_upload:
        request = http.MultipartRequest(
            method.toStringValue(), _createUri(paths, queryParameters));
        break;
      default:
        request = http.Request(
            method.toStringValue(), _createUri(paths, queryParameters));
    }
    return request;
  }

  // Returns a URI ready to be used by the HTTP client to send the request.
  Uri _createUri(Object paths, Map<String, String> queryParameters) {
    var uri = Uri.tryParse(_glpiEndpoint.endpoint);
    if (uri != null) {
      /*workaround to remove empty pathSegments,
      this no indeed a bug, but for better compatibility*/
      final it = uri.pathSegments.takeWhile((p) => p.isNotEmpty == true);
      uri = uri.replace(
          pathSegments: it.toList() +
              pathSegments(paths), //replace and/or add pathsSegments
          queryParameters: queryParameters
            ..addAll(
                uri.queryParameters)); // replace and/or add queryParameters
      return uri;
    }
    throw FormatException('Could not be resolve endpoint String to Uri.');
  }

  // Put default headers.
  void _addHeaders(
    Map<String, String> headers,
    bool enableSessionToken,
    http.BaseRequest request,
  ) {
    if (_glpiEndpoint.appToken is String) {
      headers['App-token'] = _glpiEndpoint.appToken;
    }
    if (enableSessionToken == true && sessionToken is String) {
      headers['Session-token'] = sessionToken;
    }
    headers.putIfAbsent('content-type', () => 'application/json;charset=UTF-8');
    headers.putIfAbsent('Charset', () => 'utf-8');
    request.headers.addAll(headers);
  }

  // Put body in request, when avaliable.
  void _addBody(Object body, http.Request request) {
    if (body != null) {
      request.body = toJson(body);
    }
  }

//Adds a file represented by filePath to the request.
//This method creates the necessary structure for a file to be sent to the GLPI.
// If the content-type cannot be determined, the 'application/octet-stream' will be used
  void _addFile(String filePath, http.MultipartRequest request) async {
    final f = File(p.normalize(filePath));
    final filename = p.basename(f.path);
    final name = p.basenameWithoutExtension(f.path);
    request
      ..fields['uploadManifest'] = toJson({
        'input': {
          'name': name,
          '_filename': [filename]
        }
      })
      ..files.add(await http.MultipartFile.fromBytes(
        'filename[0]',
        f.readAsBytesSync(),
        filename: filename,
        contentType: MediaType.parse(mediaType(f.path)),
      ));
  }

  // caught a exception from GLPI API error
  _throwGlpiError(String response) {
    final lst = jsonErrorToList(response);
    throw GlpiError(lst?.last, lst?.first);
  }
}
