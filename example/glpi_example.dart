import 'dart:convert';

import 'package:glpi/glpi.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';

main() async {
  var endpoint = GlpiEndpoint('http://glpiapidomain.com/apirest.php',
      appToken: 'glpiAppTokenApplicationHere');

  //var client = Client();
  Client testClient = MockClient((request) async {
    return Response(json.encode({'result': true}), 200);
  });
  
  var glpi = GlpiApi(endpoint, client: testClient);

  await glpi.initSessionByCredentials('normal', 'normal');
  await glpi.killSession();
}