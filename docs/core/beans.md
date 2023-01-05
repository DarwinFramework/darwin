# Beans

Beans can be defined as methods or fields inside [services](../../core/services/ "mention") and are lightweight framework managed dependency providers. Beans can be used to make parts of a service available for dependency injection which are not directly services themselves.

## Code Examples

{% code title="bean_example.dart" %}
```dart
import 'dart:async';

import 'package:darwin_injector/darwin_injector.dart';
import 'package:darwin_sdk/darwin.dart';

@Service()
class BeanExampleService {

  @Bean()
  String helloBean() => "Hello World!";

  @Bean()
  int age = 19;

}
```
{% endcode %}

