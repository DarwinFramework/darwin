# Decoupling

Services implementations are not required to bind to their runtime type and can therefore bind to any type they are castable to, like abstract supertypes, interfaces, mixins or dynamic types.

To decouple a service definition from its implementation, create an abstract class serving as the service definition.

```dart
abstract class MyService {
  
  void doSomething();
  void startOver();
  
}
```

After that, you can create a service implementation, extending the abstract service definiton. This implementation can then be annotated with the service annotation and define `MyService` as its binding type.

```dart
@Service(MyService)
class MyServiceImpl extends MyService {
  
  @override
  void doSomething() {
    // TODO: implement doSomething
  }

  @override
  void startOver() {
    // TODO: implement startOver
  }
}
```

{% hint style="warning" %}
Meta annotations in the bound type will be ignored by the code generator. All annotations have to applied at implementation level.
{% endhint %}
