# Beans

Beans are lightweight framework managed dependency providers and can be defined by annotating methods or fields with the Bean annotation inside [services](services/ "mention"). Beans can be used to make parts of a service available for dependency injection which are not directly services themselves.

By default, beans are injectable by their declared type and are associated with their name (method name or field name, depending on which member is annotated). To modify this behaviour, `Bean.name` and `Bean.bindingType` can be manually set. Beans can also choose to bind only to their type by using `Bean.isUnnamed`.

Beans also offer customizable loading strategies which influence when the bean methods are invoked and if their returned value is cached. Possible loading strategies include:

|                  |                                                                                     |
| ---------------- | ----------------------------------------------------------------------------------- |
| direct (default) | The member is queried when requested                                                |
| lazy             | The member is queried when requested and the return value will be cached internally |
| eager            | The member is queried once after binding and the return value is cached internally. |

## Code Examples

{% code title="bean_example.dart" %}
```dart
import 'dart:async';

import 'package:darwin_injector/darwin_injector.dart';
import 'package:darwin_sdk/darwin_sdk.dart';

@Service()
class BeanExampleService {

  @Bean()
  String helloBean() => "Hello World!";

  @Bean()
  int age = 19;

}
```
{% endcode %}
