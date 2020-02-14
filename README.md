# GLPI API Client Library for Dart developers.

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

**GLPI** is an incredible ITSM software tool that helps you plan and manage IT changes in an easy way, solve problems efficiently when they emerge and allow you to gain legitimate control over your company’s IT budget, and expenses.()
## Usage

A simple usage example:

```dart
import 'package:glpi/glpi.dart';

main() {
  var endpoint = GlpiEndpoint('http://glpiapidomain.com/apirest.php',
      appToken: 'glpiAppTokenApplicationHere');
  var glpi = GlpiApi(endpoint);
  await glpi.initSessionByCredentials('normal', 'normal');
  print(glpi.sessionToken);
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme

## Copying

* **Name**: [GLPI](http://glpi-project.org/) is a registered trademark of [Teclib'](http://www.teclib-edition.com/en/).
* **Code**: you can redistribute it and/or modify
    it under the terms of the GNU General Public License ([GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html)).