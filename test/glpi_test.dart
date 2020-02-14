import 'package:glpi/glpi.dart';
import 'package:glpi/src/query/item_criteria.dart';
import 'package:glpi/src/query/items_query.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';

void main() {
  group('Login/Logout Methods', () {
    var glpi;
    setUp(() async {
      var endpoint = GlpiEndpoint('http://10.0.0.100/glpi/apirest.php/',
          appToken: 'teste123');
      glpi = GlpiApi(endpoint);
    });
    tearDown(() async {
      await glpi.killSession(); //logout
    });
    test('GLPI login and password', () async {
      await glpi.initSessionByCredentials('normal', 'normal');
      expect(glpi.sessionToken is String, true);
    });
    test('GLPI user token', () async {
      await glpi
          .initSessionByUserToken('7ot8OBUDtkQ6yin05zO5xXzhB8n8UqDUcJBvNDcn');
      expect(glpi.sessionToken is String, true);
    });
  });
  group('Others API calls', () {
    var glpi;
    setUp(() async {
      var endpoint = GlpiEndpoint('http://10.0.0.100/glpi/apirest.php',
          appToken: 'teste123');
      glpi = GlpiApi(endpoint);
      await glpi.initSessionByCredentials('glpi', 'glpi');
    });
    test('GLPI Recovery Password', () async {
      final result = await glpi.recoveryPassword('glpi@yourdomain.com');
      print(result);
      expect(result is List<dynamic>, true);
    });
    test('GLPI Reset Password', () async {
      final result = await glpi.resetPassword(
          'glpi@yourdomain.com', 'passwordToken', 'newSecret');
      expect(result, null);
    });
    test('GLPI get my profiles', () async {
      final result = await glpi.getMyProfiles();
      print(result);
      expect((result is List), true);
    });
    test('GLPI get active profiles', () async {
      Map result = await glpi.getActiveProfile();
      print(result);
      expect((result is Map), true);
    });
    test('GLPI change active profile', () async {
      final result = await glpi.changeActiveProfile(4);
      expect(result, null);
    });
    test('GLPI get my entities', () async {
      final result = await glpi.getMyEntities(isRecursive: true);
      print(result);
      expect(result is List, true);
    });
    test('GLPI get active entities', () async {
      final result = await glpi.getActiveEntities();
      print(result);
      expect(result is Map, true);
    });
    test('GLPI change active entities', () async {
      final result =
          await glpi.changeActiveEntities(entitiesId: 0, isRecursive: null);
      print(result);
      expect(result, true);
    });
    test('GLPI get full session', () async {
      final result = await glpi.getFullSession();
      print(result);
      expect(result is Map, true);
    });
    test('GLPI get config', () async {
      final result = await glpi.getGlpiConfig();
      print(result);
      expect(result is Map, true);
    });
    test('GLPI get all items', () async {
      final result = await glpi.getAllItems(
          ItemType.User,
          AllItemsQuery(
              sort: 'phone',
              order: Order.desc,
              expandDropdowns: false,
              getHateoas: true,
              onlyId: false,
              searchText: {'name': 'normal'}));
      print(result);
      expect(result is List, true);
    });
    test('GLPI get sub items', () async {
      final result = await glpi.getSubItems(
          ItemType.User,
          5,
          ItemType.Log,
          SubItemsQuery(
            order: Order.desc,
            expandDropdowns: true,
            getHateoas: true,
          ));
      print(result);
      expect(result is List, true);
    });
    test('GLPI get item', () async {
      final result = await glpi.getItem(
          ItemType.Computer,
          15,
          ItemOptions(
              expandDropdowns: true,
              getHateoas: false,
              getSha1: true,
              withDevices: false,
              withLogs: true));
      print(result);
      expect(result is String, true);
    });
    test('GLPI get multiple items', () async {
      final result = await glpi.getMultipleItems({
        ItemType.User: [2, 5],
        ItemType.Entity: [0]
      }, ItemOptions(getSha1: true));
      print(result);
      expect(result is List, true);
    });
    test('GLPI list search option', () async {
      final result =
          await glpi.listSearchOptions(ItemType.Notepad);
    //  print(result);
      expect(result is Map, true);
    });
    test('GLPI list search item', () async {
      final result = await glpi.searchItems(
          ItemType.Monitor,
          SearchCriteria(criteria: [
            Criteria(1, SearchType.equals, 1,
                meta: true, itemType: ItemType.Notepad, link: Link.and)
          ]
          , endRange: 900));
      print(result);
      expect(result is Map, true);
    });
    test('GLPI add multiples items', () async {
      final pc1 = <String, dynamic>{'name': 'Computer One'};
      final pc2 = <String, dynamic>{'name': 'Computer Two'};
      final items = [pc1, pc2];
      final result = await glpi.addItems(ItemType.Computer, items);
      print(result);
      expect(result is List<dynamic>, true);
    });
    test('GLPI add a item', () async {
      final pc = <String, dynamic>{'name': 'Computer Three'};
      final result = await glpi.addItems(ItemType.Computer, pc);
      print(result);
      expect(result is Map<String, dynamic>, true);
    });
    test('GLPI upload a document', () async {
      final document = '/home/luiz/Documentos/Dart/glpi/file.txt';
      final result = await glpi.addItems(ItemType.Document, document);
      print(result);
      expect(result is Map, true);
    });
    test('GLPI update items', () async {
      final result = await glpi.updateItems(ItemType.Computer, [
        {'name': 'Computer Updated 1', 'id': 7},
        {'name': 'Computer Updated 2', 'id': 2}
      ]);
      print(result);
      expect(result is List, true);
    });
    test('GLPI download', () async {
      final result = await glpi.download(1, useAlt: true);
      expect(result is Response, true);
    });
    test('GLPI killSession', () async {
      await glpi.killSession();
      expect(true, true);
    });
  });
}
