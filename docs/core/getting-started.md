# Getting Started

## Initial setup

Add all necessary darwin packages to your pubspec.yaml. Remember to replace any by the versions you are actually depending on.

{% code title="pubspec.yaml" %}
```yaml
dependencies:
  shelf: any
  darwin_sdk: any
  darwin_http: any
  darwin_injector: any
  darwin_eventbus: any
  darwin_marshal: any
  [...]

dev_dependencies:
  build_runner: any
  darwin_gen: any
  darwin_http_gen: any
  [...]
```
{% endcode %}

After that, run `dart pub get` to retrieve all package dependencies. And perform initial code generation.

```bash
dart pub get
dart run build_runner build
```

In your main method, you can now configure and execute your darwin application after importing the generated `darwin.g.dart` file.

{% code title="main.dart" %}
```dart
Future main(List<String> arguments) async {
  await initialiseDarwin();
  application.watchProcessSignals = true; // Watch process signals
  application.install(HttpPlugin()); // Install http plugin
  application.install(MarshalPlugin((marshal) { // Install marshal plugin
    // Configure darwin marshal
  }));
  await application.execute(); // Run application
}
```
{% endcode %}

## Running

You must trigger the code generator before running or building your dart application for changes to apply. Following command will trigger the build runner:

```bash
dart run build_runner build
```
