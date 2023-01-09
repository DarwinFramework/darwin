# Dependencies

Services define their dependencies using unnamed required constructor parameters which must reference instance fields of the service. There is no requirement for a specific parameter order, although it is advised to follow the order of the field declarations for code style reasons.

```dart
@Service()
class ServiceExample {

  ServiceA serviceA;
  String name;
  int age;

  ServiceExample(
      this.serviceA, 
      @Named("firstname") this.name,
      @Named("age") this.age
  );
}
```

By default, all dependencies are unnamed and are therefore only resolved by their types. Beans for example additionally bind to their name, making bean dependencies not injectable via their type alone. To define the additional name scope, the [Named annotation](https://pub.dev/documentation/darwin\_injector/latest/darwin\_injector/Named-class.html) can be used on the respective constructor parameter.
