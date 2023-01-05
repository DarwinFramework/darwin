# Overview

## What is Darwin?

The Darwin Framework is a ecosystem consisting of many modules, which are designed to improve fast, modular and clean development of dart applications and packages using the [IoC-Pattern](https://en.wikipedia.org/wiki/Inversion\_of\_control).

## What does Darwin solve?

Darwin aims to solve following key problems:

* **Customizability and Exchangeability** \
  Inversion of control and dependency injection solve many problems a deeply nested monolithic application might have. The abstraction of logic into services makes it easy to replace specific parts of an implementation and allows for automatic dependency resolution which helps to minimize unwanted edge-cases. &#x20;
* **Agile Development**\
  Service based software development allows for better parallelization of work as development can be more easily distributed. Decoupling service implementations and their api definition makes feature driven development simpler and also helps preventing unwanted blocking.
* **Code Readability**\
  Writing large or medium sized applications always has a great impact on code readability - or more exactly the lack of such. Isolation of functionality improves navigation and, together with powerful code generation of darwin, massively reduces boilerplate code while still maintaining a high level of readability.&#x20;
* **Testability**\
  Darwin highly emphasizes the use of dependency injection through which both manual and automatic unit and integration testing becomes quite easy to achieve and less cumbersome.
* **Dart everywhere!**\
  With Dart being both a simple and flexible language, which is widely used for app development,  expanding the ecosystem with good backend oriented frameworks greatly increases the flexibility of dart developers.\
