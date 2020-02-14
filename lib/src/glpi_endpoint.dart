library glpi_endpoint;
/// Representation of the GLPI server endpoint. 
/// In addition to the address, 
/// the token for the client application is also determined here.
class GlpiEndpoint {

  /// Creates an endpoint for the GLPI REST API address.
  GlpiEndpoint(this._endpoint, {String appToken}) : _appToken = appToken;

  final String _endpoint;

  final String _appToken;

  /// Returns the endpoint is the URL where your API can be accessed. Read-Only
  String get endpoint => _endpoint;

  /// App(lication) token : An optional way to filter the access to the API.
  /// On API call, it will try to find an API client matching your IP 
  /// and the [appToken] (if provided)
  String get appToken => _appToken;
}
