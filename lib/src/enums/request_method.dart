/// Enum to represent HTTP methods and the two special cases of the API:
/// Download and Upload files.
enum RequestMethod {
  get,
  put,
  delete,
  patch,
  post,
  file_download,
  file_upload,
}

///Extension to get String value of [RequestMethod].
extension RequestMethods on RequestMethod {
  ///Returns a String representation of the [RequestMethod] value.
  String toStringValue() {
    switch (this) {
      case RequestMethod.get:
        return 'GET';
      case RequestMethod.post:
        return 'POST';
      case RequestMethod.put:
        return 'PUT';
      case RequestMethod.patch:
        return 'PATCH';
      case RequestMethod.delete:
        return 'DELETE';
      case RequestMethod.file_download:
        return 'GET';
      case RequestMethod.file_upload:
        return 'POST';
      default:
        return '';
    }
  }
}
