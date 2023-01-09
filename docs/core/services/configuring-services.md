# Configuring Services

Services should get configuration date from injected data sources, such as other services. Those dependencies are to be declared as stated in [dependencies.md](dependencies.md "mention"). Additionally, services can define conditions using class-level annotations, implementing the [Condition base class](https://pub.dev/documentation/darwin\_sdk/latest/darwin/Condition-class.html). Service level conditions are checked once before the service would otherwise be constructed and can prevent the service from starting and being bound. Services which decline registration are skipped and considered solved in dependency resolution.

### Conditions provided by the core library

| Condition Annotation                                                                          | Effect                                                                                                                         |
| --------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| [Profile(String)](https://pub.dev/documentation/darwin\_sdk/latest/darwin/Profile-class.html) | Requires the application to run in a specific profile for this condition to match. Inversible via the named inverse parameter. |
