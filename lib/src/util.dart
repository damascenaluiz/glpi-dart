import 'dart:convert';
import 'package:mime/mime.dart';

/// encode a string in base64 string
String encodeBase64(String str) {
  final utfEncode = utf8.encode(str);
  return base64.encode(utfEncode);
}

/// returns a list of strings from json errors response.
List<String> jsonErrorToList(String str) =>
    str.substring(1, str.length - 1).split(',');

/// Convert a id list into a string list with json format.
List<String> toJsonIds(List<int> lst) =>
    lst.map((id) => '{"id": $id}').toList();

/// Alias to json.encode method
String toJson(Object obj) => json.encode(obj);

/// Parse a json response
dynamic fromJson(String response) =>
    response.isNotEmpty ? json.decode(response) : {};

/// Convert a path to a list
List<String> pathSegments(Object paths) =>
    (paths is List<String>) ? paths : [paths.toString()];

/// Returns the string containing only the name of the enum
String enumToString(Object e) => e.toString().split('.').last;

///Returns the MIME-type of a file, if not found, 'application/octet-stream' is returned.
String mediaType(String filepath) =>
    lookupMimeType(filepath) ?? 'application/octet-stream';
/*
//Returns the file name from content-disposition
String filenameFromContent(String contentDisposition) {
  final RegExp regexFilename = RegExp(r'filename=[\"]?([\w\._-\s]+)[\"]?');
  if (regexFilename.hasMatch(contentDisposition)) {
    final match = regexFilename.firstMatch(contentDisposition);
    final filename = match.group(1);
    return filename;
  }
  return null;
}
Future<File> _fileDownload(http.Response response) async {
    var bytes = response.bodyBytes;
    var content = response.headers['content-disposition'];
    var filename = filenameFromContent(content);
    File file = File(filename ?? 'document');
    return await file.writeAsBytes(bytes);
  }
  */
