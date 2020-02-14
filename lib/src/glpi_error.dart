///When the response from the endpoint is an error,
///it is converted to an instance of this class.
class GlpiError extends Error {
  final String _errorCode;
  final String _message;

  /// GLPI error received. Read-only.
  String get errorCode => _errorCode;

  ///  Specific message about the error. Read-only.
  String get message => _message;

  ///Constructor.
  GlpiError([String message, String errorCode])
      : _message = message,
        _errorCode = errorCode;

  /// List of possible HTTP errors recevied from GLPI through of a request.
  static const List<int> errors = [400, 401, 404];

  ///Returns an [GlpiError] as a string.
  @override
  String toString() =>
      "[GlpiError]" +
      ((_message != null) ? ' Message: $_message' : '') +
      ((_errorCode != null) ? ' Error Code: $_errorCode' : '');
}