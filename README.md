<h1>
    Darwin
    <a href="https://pub.dev/packages/darwin_sdk">
        <img src="https://img.shields.io/pub/v/darwin_sdk" alt="discord">
    </a>
    <a href="https://discord.gg/6HKuGSzYKJ">
        <img src="https://img.shields.io/discord/1060355106522017924?label=discord" alt="discord">
    </a>
    <a href="https://helightdev.gitbook.io/darwin">
        <img src="https://img.shields.io/badge/docs-gitbook.com-346ddb.svg" alt="gitbook">
    </a>
    <a href="https://github.com/invertase/melos">
        <img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg" alt="melos">
    </a>
</h1>

Darwin is your swiss army knife for creating service based applications
in dart, using the inversion of control principle and
a powerful annotation based code-generator.

## Goals
- 🪟 **Clear and readable!**
with almost zero boilerplate and services.
- 🔋 **Batteries included!**
plus a variety of packages and integrations.
- 🚄 **We are speed!**
Fast startups and delayable code generation.
- 🎨 **Make it your own!**
Many extension points and configurations.

## Have a look for yourself!
```dart
@RestController()
@RequestMapping("/api/cats")
class CatController {

  CatService service;
  CatController(this.service);

  @GetMapping("%name%")
  Cat retrieveCat(@PathParameter() String name) {
    return service.getNamedCat(name);
  }

  @PostMapping()
  Cat saveCat(@Body() cat) => service.addCat(cat);

  @GetMapping()
  List<Cat> retrieveAll() => service.getAllCats();

}
```

## Silent Code Generation
A neat point about darwins **non-intrusive** code generation is, that it
has almost **zero boilerplate** and generally **doesn't require importing
or referencing generated source code**, except for just a few cases.
This allows you to keep on working on your code, without having to wait
for the build runner to create your required files for every new service
you create and plan to use. This also **minimizes conflicts** with other
external generators and helps to prevent unexpected build runner crashes.
